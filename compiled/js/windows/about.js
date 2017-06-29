(function() {
  var BrowserWindow, about;

  about = {
    win: null
  };

  BrowserWindow = require('electron').BrowserWindow;

  about.init = function() {
    if (about.win) {
      return about.win.show();
    }
    about.win = new BrowserWindow({
      backgroundColor: '#ECECEC',
      center: true,
      fullscreen: false,
      height: 170,
      maximizable: false,
      minimizable: false,
      resizable: false,
      show: false,
      skipTaskbar: true,
      useContentSize: true,
      width: 300
    });
    about.win.loadURL("file://" + __dirname + "/../../html/about.html");
    about.win.setMenu(null);
    about.win.once('ready-to-show', about.win.show);
    return about.win.once('closed', function() {
      return about.win = null;
    });
  };

  module.exports = about;

}).call(this);
