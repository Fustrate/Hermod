WebSocketClient = require('websocket').client
WebSocketConnection = require('websocket').connection

class WebsocketConnection
  constructor: (@token, @debug = false) ->
    @client = new WebSocketClient()
    @queue = []
    @eventListeners = {}

    @client.on 'connectFailed', (error) =>
      @received 'connection.failed', error.toString()

    @client.on 'connect', (@connection) =>
      @connection.on 'error', (error) =>
        @received 'connection.error', error.toString()

      @connection.on 'close', =>
        @received 'connection.closed'

      @connection.on 'message', (message) =>
        [name, data] = JSON.parse message.utf8Data

        @received(name, data)

    @send 'connection.authenticate', token: @token

    @addEventListeners()

  addEventListeners: =>
    @on 'connection.opened', =>
      # Make a copy of the queue so we're not endlessly cycling
      [queuedMessages, @queue] = [@queue, []]

      @sendRaw message, false for message in queuedMessages

    @on 'connection.ping', =>
      @send 'connection.pong'

  on: (name, callback) =>
    @eventListeners[name] ?= []
    @eventListeners[name].push callback

  isOpen: =>
    @connection and @connection.state is 'open'

  send: (name, data = null) =>
    @sendRaw JSON.stringify([name, data])

  sendRaw: (message, queue = true) =>
    unless @isOpen()
      @queue.push message if queue

      return

    if @debug
      console.log 'Sent', message

    @connection.sendUTF message

  received: (name, data) =>
    callbacks = @eventListeners[name]

    if @debug
      console.log 'Received', name, data

    if callbacks
      callback data for callback in callbacks
      # console.log 'handled event', name, data if @debug
    else
      console.log 'Unhandled', name, data

  connect: =>
    @client.connect "#{@websocketUrl()}?version=2.0.0-alpha"

  disconnect: (reason) =>
    @connection?.close(reason ? WebSocketConnection.CLOSE_REASON_NORMAL)

  websocketUrl: =>
    if @debug
      'ws://0.0.0.0:9292/'
    else
      'wss://valenciamgmt.net/messenger/'

module.exports = WebsocketConnection
