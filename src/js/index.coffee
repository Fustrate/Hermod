app = require 'app'
BrowserWindow = require 'browser-window'

# Report crashes to our server.
require('crash-reporter').start()

# Keep a global reference of the window object, if you don't, the window will
# be closed automatically when the JavaScript object is garbage collected.
mainWindow = null

# Quit when all windows are closed.
app.on 'window-all-closed', ->
  # On OS X it is common for applications and their menu bar
  # to stay active until the user quits explicitly with Cmd + Q
  app.quit() if process.platform != 'darwin'

# This method will be called when Electron has finished
# initialization and is ready to create browser windows.
app.on 'ready', ->
  if false
    mainWindow = new BrowserWindow(width: 300, height: 750)
    mainWindow.loadUrl "file://#{__dirname}/../html/main.html"
  else
    mainWindow = new BrowserWindow(width: 300, height: 450)
    mainWindow.loadUrl "file://#{__dirname}/../html/authenticate.html"

  # require('node-notifier').notify(
  #   title: 'My notification'
  #   message: 'Hello, there!'
  #   sound: true
  # )

  # Emitted when the window is closed.
  mainWindow.on 'closed', ->
    # Dereference the window object, usually you would store windows
    # in an array if your app supports multi windows, this is the time
    # when you should delete the corresponding element.
    mainWindow = null
