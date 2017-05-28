electron = require('electron')
{ app, BrowserWindow } = electron

idle = require '@paulcbetts/system-idle-time'
keytar = require 'keytar'

WebsocketConnection = require './websocket_connection'

class Messenger
  @IDLE_TIME: 10 * 60 * 1000
  @DEBUG: true

  mainWindow: null
  authWindow: null
  websocket: null
  userList: []
  userStatuses: {}

  messageWindows: {}

  status: 'online'
  idle: false

  constructor: ->
    setInterval @checkIdleTime, 1000

    keytar.getPassword('valenciamgmt.net', 'authToken').then (@authToken) =>
      if @authToken
        @openMainWindow()
      else
        @openAuthWindow()

    electron.powerMonitor
      .on 'sleep', @disconnectWebsocket
      .on 'wake', @reconnectWebsocket

  disconnectWebsocket: ->

  reconnectWebsocket: =>
    console.log 'Woke from sleep'

    @websocket.connect()

  startWebsocketConnection: =>
    @websocket = new WebsocketConnection @authToken, @constructor.DEBUG

    @websocket.on 'employees.list',           @updateUserList
    @websocket.on 'employees.statuses',       @updateStatuses
    @websocket.on 'connection.authenticated', @connectionAuthenticated
    @websocket.on 'unread_count',             @updateUnreadCount
    @websocket.on 'new_message',              @showConversation
    @websocket.on 'message.sent',             @messageSent

    @websocket.on 'connection.failed', =>
      @mainWindow?.webContents.send 'setConnectionStatus', 'Connection Failed'

    @websocket.on 'connection.opened', =>
      @mainWindow?.webContents.send 'setConnectionStatus', 'Connected'

    @websocket.on 'connection.closed', =>
      @mainWindow?.webContents.send 'setConnectionStatus', 'Disconnected'

    @websocket.connect()

  messageSent: ->

  updateUserList: (@userList) =>
    @mainWindow.webContents.send 'employees_list', @userList

  connectionAuthenticated: (user_info) =>
    @id = user_info.id
    @editor =
      font_family: user_info.font_family
      font_size: user_info.font_size
      font_color: user_info.font_color

  updateStatuses: (@userStatuses) =>
    @mainWindow.webContents.send 'employees_statuses', @userStatuses
    @mainWindow.webContents.send 'setDisplayedStatus', @userStatuses[@id]

  updateUnreadCount: (count) =>
    @unread = parseInt count, 10
    @mainWindow.webContents.send 'unread_count', @unread

  showConversation: (conversation) ->
    unless @messageWindows[conversation.id]
      @messageWindows[conversation.id] = new BrowserWindow
        width: 600
        height: 500
        'min-width': 200
        show: false

      @messageWindows[conversation.id]
        .loadURL "file://#{__dirname}/../html/conversation.html"
      @messageWindows[conversation.id]
        .on 'closed', =>
          delete @messageWindows[conversation.id]

    @messageWindows[conversation.id].webContents.send 'update', conversation
    @messageWindows[conversation.id]
      .show()
      .flashFrame(true)

  checkIdleTime: =>
    return unless @websocket

    if idle.getIdleTime() < @constructor.IDLE_TIME
      if @idle
        @websocket.send 'user.status', @status
        @idle = false
    else if not @idle
      @idle = true
      @websocket.send 'user.status', 'idle'

  openMainWindow: =>
    @mainWindow ?= new BrowserWindow
      width: 600
      height: 500
      'max-width': 600
      'min-width': 200

    @mainWindow.loadURL "file://#{__dirname}/../html/main.html"
    @mainWindow.focus()

    setTimeout @startWebsocketConnection, 1000

  openAuthWindow: =>
    @authWindow ?= new BrowserWindow
      width: 300
      height: 450
      'max-width': 600
      'min-width': 200

    @authWindow.loadURL "file://#{__dirname}/../html/authenticate.html"
    @authWindow.on 'close', => @authWindow = null

module.exports = Messenger
