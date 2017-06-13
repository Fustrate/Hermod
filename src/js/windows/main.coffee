mainWindow = { win: null }

{ BrowserWindow } = require 'electron'

mainWindow.send = (name, data) ->
  return unless mainWindow.win

  mainWindow.win.webContents.send(name, data)

mainWindow.init = ->
  return mainWindow.win.show() if mainWindow.win

  mainWindow.win = new BrowserWindow
    width: 600
    height: 600
    maxWidth: 600
    minWidth: 200
    show: false

  mainWindow.win
    .loadURL "file://#{__dirname}/../../html/main.html"

  # No menu on the Authentication window
  mainWindow.win.setMenu null

  mainWindow.win.once 'ready-to-show', ->
    mainWindow.win.show()
    mainWindow.win.focus()

  mainWindow.win.once 'closed', ->
    mainWindow.win = null

module.exports = mainWindow
