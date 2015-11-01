WebSocketClient = require('websocket').client
WebSocketConnection = require('websocket').connection

class WebsocketConnection
  constructor: (@token) ->
    @client = new WebSocketClient()
    @queue = []
    @eventListeners = {}

    @client.on 'connectFailed', (error) ->
      console.log "Connect Failed: #{error.toString()}"

    @client.on 'connect', (@connection) =>
      @connection.on 'error', (error) ->
        console.log "Connection Error: #{error.toString()}"

      @connection.on 'close', ->
        console.log('Connection Closed')

      @connection.on 'message', (message) =>
        [name, data] = JSON.parse message.utf8Data

        @receivedEvent(name, data)

    @send 'connection.authenticate', token: @token

    @addEventListeners()

  addEventListeners: =>
    @on 'connection.opened', =>
      console.log 'Connection Opened'

      # Make a copy of the queue so we're not endlessly cycling
      [queuedMessages, @queue] = [@queue, []]

      for message in queuedMessages
        console.log 'Trying to send again', message
        @sendRaw message, false

    @on 'connection.ping', =>
      @send 'connection.pong'

  on: (name, callback) =>
    @eventListeners[name] ?= []
    @eventListeners[name].push callback

  isOpen: =>
    @connection && @connection.state == 'open'

  send: (name, data = null) =>
    @sendRaw JSON.stringify([name, data])

  sendRaw: (message, queue = true) =>
    unless @isOpen()
      @queue.push message if queue

      return

    # console.log 'websocket sent', message

    @connection.sendUTF message

  receivedEvent: (name, data) =>
    callbacks = @eventListeners[name]

    if callbacks
      callback data for callback in callbacks
    else
      console.log 'unhandled event', name, data

  connect: ->
    @client.connect('wss://valenciamgmt.net/messenger/?version=2.0.0-alpha')

module.exports = WebsocketConnection
