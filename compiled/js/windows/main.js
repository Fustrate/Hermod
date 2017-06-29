(function() {
  var BrowserWindow, mainWindow;

  mainWindow = {
    win: null
  };

  BrowserWindow = require('electron').BrowserWindow;

  mainWindow.send = function(name, data) {
    if (!mainWindow.win) {
      return;
    }
    return mainWindow.win.webContents.send(name, data);
  };

  mainWindow.init = function() {
    if (mainWindow.win) {
      return mainWindow.win.show();
    }
    mainWindow.win = new BrowserWindow({
      width: 600,
      height: 600,
      maxWidth: 600,
      minWidth: 200,
      show: false
    });
    mainWindow.win.loadURL("file://" + __dirname + "/../../html/main.html");
    mainWindow.win.setMenu(null);
    mainWindow.win.once('ready-to-show', function() {
      mainWindow.win.show();
      return mainWindow.win.focus();
    });
    return mainWindow.win.once('closed', function() {
      return mainWindow.win = null;
    });
  };

  module.exports = mainWindow;

}).call(this);
