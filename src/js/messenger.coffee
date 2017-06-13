electron = require('electron')
{ app, BrowserWindow, ipcMain } = electron

idle = require '@paulcbetts/system-idle-time'
keytar = require 'keytar'

WebsocketConnection = require './websocket_connection'

class Messenger
  @IDLE_TIME: 10 * 60 * 1000
  @DEBUG: true

  mainWindow: null
  websocket: null
  userList: []
  userStatuses: {}

  # Windows for each active conversation
  conversations: {}

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

    ipcMain.on 'new_message', (event, users) =>
      @openMessageWindow(users)

    ipcMain.on 'about', @openAboutWindow

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

    app.setBadgeCount @unread

  showConversation: (conversation) ->
    unless @conversations[conversation.id]
      @conversations[conversation.id] = new BrowserWindow
        width: 600
        height: 720
        minWidth: 200
        show: false

      @conversations[conversation.id]
        .loadURL "file://#{__dirname}/../html/conversation.html"
      @conversations[conversation.id]
        .on 'closed', =>
          delete @conversations[conversation.id]
        .on 'focus', =>
          @conversations[conversation.id].setAlwaysOnTop(false)
        .once 'ready-to-show', =>
          @conversations[conversation.id].show()

    @conversations[conversation.id].webContents.send 'update', conversation
    @conversations[conversation.id]
      .flashFrame(true)
      .setAlwaysOnTop(true)

  checkIdleTime: =>
    return unless @websocket

    if idle.getIdleTime() < @constructor.IDLE_TIME
      return unless @idle

      @websocket.send 'user.status', @status
      @idle = false
    else if not @idle
      @idle = true
      @websocket.send 'user.status', 'idle'

  openMainWindow: =>
    @mainWindow ?= new BrowserWindow
      width: 600
      height: 600
      maxWidth: 600
      minWidth: 200

    @mainWindow.loadURL "file://#{__dirname}/../html/main.html"
    @mainWindow.focus()

    setTimeout @startWebsocketConnection, 1000

  openAuthWindow: =>
    @authentication ?= require('./windows/authentication')

    @authentication.init()

  openAboutWindow: =>
    @about ?= require('./windows/about')

    @about.init()

  openMessageWindow: (users) =>
    @new_message ?= require('./windows/new_message')

    @new_message.init(users)

module.exports = Messenger
