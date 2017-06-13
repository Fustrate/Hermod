authentication = { win: null }

{ BrowserWindow } = require 'electron'

authentication.init = ->
  return authentication.win.show() if authentication.win

  authentication.win = new BrowserWindow
    center: true
    fullscreen: false
    height: 450
    maximizable: false
    maxWidth: 600
    minimizable: false
    minWidth: 200
    resizable: false
    show: false
    useContentSize: true
    width: 300

  authentication.win
    .loadURL "file://#{__dirname}/../../html/authentication.html"

  # No menu on the Authentication window
  authentication.win.setMenu null

  authentication.win.once 'ready-to-show', authentication.win.show

  authentication.win.once 'closed', ->
    authentication.win = null

module.exports = authentication
