conversations = { windows: [] }

{ BrowserWindow } = require('electron')

conversations.init = (jsonData) ->
  conversation = JSON.decode data

  if conversations.windows[conversation.id]
    # Send the new data to the window
    conversations.windows[conversation.id].webContents.send 'update', jsonData
  else
    conversations.windows[conversation.id] = new BrowserWindow
      width: 600
      height: 720
      minWidth: 200
      show: false

    conversations.windows[conversation.id].once 'ready-to-show', ->
      conversations.windows[conversation.id].show()
    conversations.windows[conversation.id].once 'closed', ((id) ->
      -> delete conversations.windows[id]
    )(conversation.id)

    conversations.windows[conversation.id].on 'focus', ->
      conversations.windows[conversation.id].setAlwaysOnTop(false)

    conversations.windows[conversation.id]
      .flashFrame(true)
      .setAlwaysOnTop(true)

    args = encodeURIComponent jsonData

    conversations.windows[conversation.id]
      .loadURL "file://#{__dirname}/../../html/conversation.html##{args}"

module.exports = conversations
