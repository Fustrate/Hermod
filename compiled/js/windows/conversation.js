(function() {
  var BrowserWindow, conversations;

  conversations = {
    windows: []
  };

  BrowserWindow = require('electron').BrowserWindow;

  conversations.init = function(jsonData) {
    var args, conversation;
    conversation = JSON.decode(data);
    if (conversations.windows[conversation.id]) {
      return conversations.windows[conversation.id].webContents.send('update', jsonData);
    } else {
      conversations.windows[conversation.id] = new BrowserWindow({
        width: 600,
        height: 720,
        minWidth: 200,
        show: false
      });
      conversations.windows[conversation.id].once('ready-to-show', function() {
        return conversations.windows[conversation.id].show();
      });
      conversations.windows[conversation.id].once('closed', (function(id) {
        return function() {
          return delete conversations.windows[id];
        };
      })(conversation.id));
      conversations.windows[conversation.id].on('focus', function() {
        return conversations.windows[conversation.id].setAlwaysOnTop(false);
      });
      conversations.windows[conversation.id].flashFrame(true).setAlwaysOnTop(true);
      args = encodeURIComponent(jsonData);
      return conversations.windows[conversation.id].loadURL("file://" + __dirname + "/../../html/conversation.html#" + args);
    }
  };

  module.exports = conversations;

}).call(this);
