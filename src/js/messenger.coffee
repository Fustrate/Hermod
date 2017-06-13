electron = require('electron')
{ app, BrowserWindow, ipcMain } = electron

idle = require '@paulcbetts/system-idle-time'
keytar = require 'keytar'

WebsocketConnection = require './websocket_connection'

class Messenger
  @IDLE_TIME: 10 * 60 * 1000
  @DEBUG: true

  websocket: null
  userList: []
  userStatuses: {}

  status: 'online'
  idle: false

  windows:
    about: require('./windows/about')
    authentication: require('./windows/authentication')
    conversations: require('./windows/conversation')
    main: require('./windows/main')
    new_messages: require('./windows/new_message')

  constructor: ->
    setInterval @checkIdleTime, 1000

    keytar.getPassword('valenciamgmt.net', 'authToken').then (@authToken) =>
      if @authToken
        @openMainWindow()
      else
        @windows.authentication.init()

    electron.powerMonitor
      .on 'sleep', @disconnectWebsocket
      .on 'wake', @reconnectWebsocket

    ipcMain.on 'new_message', (event, users) =>
      @windows.new_messages.init(users)

    ipcMain.on 'about', =>
      @windows.about.init()

  openMainWindow: =>
    @windows.main.init()

    setTimeout @startWebsocketConnection, 1000

  startWebsocketConnection: =>
    return if @websocket

    @websocket = new WebsocketConnection @authToken, @constructor.DEBUG

    @websocket
      .on 'connection.authenticated', @connectionAuthenticated
      .on 'connection.closed', @connectionClosed
      .on 'connection.failed', @connectionFailed
      .on 'connection.opened', @connectionOpened
      .on 'employee.unread_count', @updateUnreadCount
      .on 'employees.list', @updateUserList
      .on 'employees.statuses', @updateStatuses
      .on 'message.new', @openConversationWindow
      .on 'message.sent', @messageSent

    @websocket.connect()

  disconnectWebsocket: ->

  reconnectWebsocket: =>
    console.log 'Woke from sleep'

    @websocket.connect()

  checkIdleTime: =>
    return unless @websocket

    if idle.getIdleTime() < @constructor.IDLE_TIME
      return unless @idle

      @websocket.send 'employee.status', @status
      @idle = false
    else if not @idle
      @idle = true
      @websocket.send 'employee.status', 'idle'

  # ----------------------------------------------------------------------------
  # Websocket Callbacks
  # ----------------------------------------------------------------------------

  openConversationWindow: (conversation) =>
    @windows.conversations.init(conversation)

  messageSent: ->

  updateUserList: (@userList) =>
    @windows.main.send 'employees_list', @userList

  connectionFailed: =>
    @windows.main.send 'setConnectionStatus', 'Connection Failed'

  connectionOpened: =>
    @windows.main.send 'setConnectionStatus', 'Connected'

  connectionClosed: =>
    @windows.main.send 'setConnectionStatus', 'Disconnected'

  connectionAuthenticated: (user_info) =>
    @id = user_info.id

    @editor =
      font_family: user_info.font_family
      font_size: user_info.font_size
      font_color: user_info.font_color

  updateStatuses: (@userStatuses) =>
    @windows.main.send 'employees_statuses', @userStatuses
    @windows.main.send 'setDisplayedStatus', @userStatuses[@id]

  updateUnreadCount: (count) =>
    @unread = parseInt count, 10

    @windows.main.send 'unread_count', @unread

    app.setBadgeCount @unread

module.exports = Messenger
