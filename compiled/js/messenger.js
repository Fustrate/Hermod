(function() {
  var BrowserWindow, Messenger, WebsocketConnection, app, electron, idle, ipcMain, keytar,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  electron = require('electron');

  app = electron.app, BrowserWindow = electron.BrowserWindow, ipcMain = electron.ipcMain;

  idle = require('@paulcbetts/system-idle-time');

  keytar = require('keytar');

  WebsocketConnection = require('./websocket_connection');

  Messenger = (function() {
    Messenger.IDLE_TIME = 10 * 60 * 1000;

    Messenger.DEBUG = true;

    Messenger.prototype.websocket = null;

    Messenger.prototype.userList = [];

    Messenger.prototype.userStatuses = {};

    Messenger.prototype.status = 'online';

    Messenger.prototype.idle = false;

    Messenger.prototype.windows = {
      about: require('./windows/about'),
      authentication: require('./windows/authentication'),
      conversations: require('./windows/conversation'),
      main: require('./windows/main'),
      new_messages: require('./windows/new_message')
    };

    function Messenger() {
      this.updateUnreadCount = bind(this.updateUnreadCount, this);
      this.updateStatuses = bind(this.updateStatuses, this);
      this.connectionAuthenticated = bind(this.connectionAuthenticated, this);
      this.connectionClosed = bind(this.connectionClosed, this);
      this.connectionOpened = bind(this.connectionOpened, this);
      this.connectionFailed = bind(this.connectionFailed, this);
      this.updateUserList = bind(this.updateUserList, this);
      this.openConversationWindow = bind(this.openConversationWindow, this);
      this.checkIdleTime = bind(this.checkIdleTime, this);
      this.reconnectWebsocket = bind(this.reconnectWebsocket, this);
      this.startWebsocketConnection = bind(this.startWebsocketConnection, this);
      this.openMainWindow = bind(this.openMainWindow, this);
      setInterval(this.checkIdleTime, 1000);
      keytar.getPassword('valenciamgmt.net', 'authToken').then((function(_this) {
        return function(authToken) {
          _this.authToken = authToken;
          if (_this.authToken) {
            return _this.openMainWindow();
          } else {
            return _this.windows.authentication.init();
          }
        };
      })(this));
      electron.powerMonitor.on('sleep', this.disconnectWebsocket).on('wake', this.reconnectWebsocket);
      ipcMain.on('new_message', (function(_this) {
        return function(event, users) {
          return _this.windows.new_messages.init(users);
        };
      })(this));
      ipcMain.on('about', (function(_this) {
        return function() {
          return _this.windows.about.init();
        };
      })(this));
    }

    Messenger.prototype.openMainWindow = function() {
      this.windows.main.init();
      return setTimeout(this.startWebsocketConnection, 1000);
    };

    Messenger.prototype.startWebsocketConnection = function() {
      if (this.websocket) {
        return;
      }
      this.websocket = new WebsocketConnection(this.authToken, this.constructor.DEBUG);
      this.websocket.on('connection.authenticated', this.connectionAuthenticated).on('connection.closed', this.connectionClosed).on('connection.failed', this.connectionFailed).on('connection.opened', this.connectionOpened).on('employee.unread_count', this.updateUnreadCount).on('employees.list', this.updateUserList).on('employees.statuses', this.updateStatuses).on('message.new', this.openConversationWindow).on('message.sent', this.messageSent);
      return this.websocket.connect();
    };

    Messenger.prototype.disconnectWebsocket = function() {};

    Messenger.prototype.reconnectWebsocket = function() {
      console.log('Woke from sleep');
      return this.websocket.connect();
    };

    Messenger.prototype.checkIdleTime = function() {
      if (!this.websocket) {
        return;
      }
      if (idle.getIdleTime() < this.constructor.IDLE_TIME) {
        if (!this.idle) {
          return;
        }
        this.websocket.send('employee.status', this.status);
        return this.idle = false;
      } else if (!this.idle) {
        this.idle = true;
        return this.websocket.send('employee.status', 'idle');
      }
    };

    Messenger.prototype.openConversationWindow = function(conversation) {
      return this.windows.conversations.init(conversation);
    };

    Messenger.prototype.messageSent = function() {};

    Messenger.prototype.updateUserList = function(userList) {
      this.userList = userList;
      return this.windows.main.send('employees_list', this.userList);
    };

    Messenger.prototype.connectionFailed = function() {
      return this.windows.main.send('setConnectionStatus', 'Connection Failed');
    };

    Messenger.prototype.connectionOpened = function() {
      return this.windows.main.send('setConnectionStatus', 'Connected');
    };

    Messenger.prototype.connectionClosed = function() {
      return this.windows.main.send('setConnectionStatus', 'Disconnected');
    };

    Messenger.prototype.connectionAuthenticated = function(user_info) {
      this.id = user_info.id;
      return this.editor = {
        font_family: user_info.font_family,
        font_size: user_info.font_size,
        font_color: user_info.font_color
      };
    };

    Messenger.prototype.updateStatuses = function(userStatuses) {
      this.userStatuses = userStatuses;
      this.windows.main.send('employees_statuses', this.userStatuses);
      return this.windows.main.send('setDisplayedStatus', this.userStatuses[this.id]);
    };

    Messenger.prototype.updateUnreadCount = function(count) {
      this.unread = parseInt(count, 10);
      this.windows.main.send('unread_count', this.unread);
      return app.setBadgeCount(this.unread);
    };

    return Messenger;

  })();

  module.exports = Messenger;

}).call(this);
