new_message = { windows: [] }

{ BrowserWindow } = require('electron')

new_message.init = (users) ->
  win = new BrowserWindow
    width: 300
    height: 450
    maxWidth: 600
    minWidth: 300
    show: false

  new_message.windows[win.id] = win

  args = encodeURIComponent users

  win.once 'ready-to-show', win.show
  win.once 'closed', ((id) ->
    -> delete new_message.windows[id]
  )(win.id)

  win.loadURL "file://#{__dirname}/../../html/new_message.html##{args}"

module.exports = new_message
