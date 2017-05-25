{app, BrowserWindow, ipcMain, crashReporter} = require('electron')
Messenger = require './messenger'

# Report crashes to our server.
# crashReporter.start(
#   productName: 'Hermod',
#   companyName: 'Valencia Management Group',
#   submitURL: 'https://your-domain.com/url-to-submit',
#   uploadToServer: true
# )

ipcMain.on 'debug', (event, args)->
  console.log args

app.on 'ready', ->
  new Messenger
