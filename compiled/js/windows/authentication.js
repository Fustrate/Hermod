(function() {
  var BrowserWindow, authentication;

  authentication = {
    win: null
  };

  BrowserWindow = require('electron').BrowserWindow;

  authentication.init = function() {
    if (authentication.win) {
      return authentication.win.show();
    }
    authentication.win = new BrowserWindow({
      center: true,
      fullscreen: false,
      height: 450,
      maximizable: false,
      maxWidth: 600,
      minimizable: false,
      minWidth: 200,
      show: false,
      useContentSize: true,
      width: 300
    });
    authentication.win.loadURL("file://" + __dirname + "/../../html/authentication.html");
    authentication.win.setMenu(null);
    authentication.win.once('ready-to-show', authentication.win.show);
    return authentication.win.once('closed', function() {
      return authentication.win = null;
    });
  };

  module.exports = authentication;

}).call(this);
