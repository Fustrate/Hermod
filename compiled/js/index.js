(function() {
  var Messenger, app, ipcMain, ref;

  ref = require('electron'), app = ref.app, ipcMain = ref.ipcMain;

  Messenger = require('./messenger');

  ipcMain.on('debug', function(event, args) {
    return console.log(args);
  });

  app.on('ready', function() {
    return new Messenger;
  });

}).call(this);
