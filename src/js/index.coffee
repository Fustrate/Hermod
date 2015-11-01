app = require 'app'
ipc = require 'ipc'
keytar = require 'keytar'
BrowserWindow = require 'browser-window'
WebsocketConnection = require './websocket_connection'
idle = require '@paulcbetts/system-idle-time'

# Report crashes to our server.
require('crash-reporter').start()

ipc.on 'debug', ->
  console.log arguments

class Messenger
  @IDLE_TIME: 10 * 60 * 1000

  mainWindow: null
  authWindow: null
  websocket: null

  status: 'online'
  idle: false

  constructor: ->
    storedToken = keytar.getPassword 'valenciamgmt.net', 'authToken'

    if storedToken
      @websocket = new WebsocketConnection storedToken

      @websocket.on 'users.list', (roles) =>
        @mainWindow?.webContents.send 'users.list', roles

      @websocket.on 'users.statuses', (users) =>
        @mainWindow?.webContents.send 'users.statuses', users

      @websocket.on 'connection.authenticated', (me) =>
        @id = me.id
        @editor =
          font_family: me.font_family
          font_size: me.font_size
          font_color: me.font_color

      @websocket.on 'unread_count', (count) ->
        @unread = parseInt(count, 10)
        @mainWindow?.webContents.send 'unread_count', @unread

      @websocket.connect()

      @openMainWindow()
    else
      @openAuthWindow()

  checkIdleTime: =>
    if idle.getIdleTime() < @constructor.IDLE_TIME
      if @idle
        @websocket.send 'user.status', @status
        @idle = false
    else if !@idle
      @idle = true
      @websocket.send 'user.status', 'idle'

  openMainWindow: =>
    unless @mainWindow
      @mainWindow = new BrowserWindow
        width: 300,
        height: 750,
        'max-width': 600,
        'min-width': 200

      @mainWindow.loadUrl "file://#{__dirname}/../html/main.html"

  openAuthWindow: =>
    unless @authWindow
      @authWindow = new BrowserWindow
        width: 300,
        height: 450,
        'max-width': 600,
        'min-width': 200

      @authWindow.loadUrl "file://#{__dirname}/../html/authenticate.html"
      @authWindow.on 'close', => @authWindow = null

# This method will be called when Electron has finished
# initialization and is ready to create browser windows.
app.on 'ready', ->
  messenger = new Messenger

  setInterval messenger.checkIdleTime, 5000
