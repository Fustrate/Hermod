(function() {
  var WebSocketClient, WebSocketConnection, WebsocketConnection,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  WebSocketClient = require('websocket').client;

  WebSocketConnection = require('websocket').connection;

  WebsocketConnection = (function() {
    function WebsocketConnection(token, debug) {
      this.token = token;
      this.debug = debug != null ? debug : false;
      this.websocketUrl = bind(this.websocketUrl, this);
      this.disconnect = bind(this.disconnect, this);
      this.connect = bind(this.connect, this);
      this.received = bind(this.received, this);
      this.sendRaw = bind(this.sendRaw, this);
      this.send = bind(this.send, this);
      this.isOpen = bind(this.isOpen, this);
      this.on = bind(this.on, this);
      this.addEventListeners = bind(this.addEventListeners, this);
      this.client = new WebSocketClient();
      this.queue = [];
      this.eventListeners = {};
      this.client.on('connectFailed', (function(_this) {
        return function(error) {
          return _this.received('connection.failed', error.toString());
        };
      })(this));
      this.client.on('connect', (function(_this) {
        return function(connection) {
          _this.connection = connection;
          _this.connection.on('error', function(error) {
            return _this.received('connection.error', error.toString());
          });
          _this.connection.on('close', function() {
            return _this.received('connection.closed');
          });
          return _this.connection.on('message', function(message) {
            var data, name, ref;
            ref = JSON.parse(message.utf8Data), name = ref[0], data = ref[1];
            return _this.received(name, data);
          });
        };
      })(this));
      this.send('connection.authenticate', {
        token: this.token
      });
      this.addEventListeners();
    }

    WebsocketConnection.prototype.addEventListeners = function() {
      this.on('connection.opened', (function(_this) {
        return function() {
          var i, len, message, queuedMessages, ref, results;
          ref = [_this.queue, []], queuedMessages = ref[0], _this.queue = ref[1];
          results = [];
          for (i = 0, len = queuedMessages.length; i < len; i++) {
            message = queuedMessages[i];
            results.push(_this.sendRaw(message, false));
          }
          return results;
        };
      })(this));
      return this.on('connection.ping', (function(_this) {
        return function() {
          return _this.send('connection.pong');
        };
      })(this));
    };

    WebsocketConnection.prototype.on = function(name, callback) {
      var base;
      if ((base = this.eventListeners)[name] == null) {
        base[name] = [];
      }
      this.eventListeners[name].push(callback);
      return this;
    };

    WebsocketConnection.prototype.isOpen = function() {
      return this.connection && this.connection.state === 'open';
    };

    WebsocketConnection.prototype.send = function(name, data) {
      if (data == null) {
        data = null;
      }
      return this.sendRaw(JSON.stringify([name, data]));
    };

    WebsocketConnection.prototype.sendRaw = function(message, queue) {
      if (queue == null) {
        queue = true;
      }
      if (!this.isOpen()) {
        if (queue) {
          this.queue.push(message);
        }
        return;
      }
      if (this.debug) {
        console.log('Sent', message);
      }
      return this.connection.sendUTF(message);
    };

    WebsocketConnection.prototype.received = function(name, data) {
      var callback, callbacks, i, len, results;
      callbacks = this.eventListeners[name];
      if (this.debug) {
        console.log('Received', name, data);
      }
      if (callbacks) {
        results = [];
        for (i = 0, len = callbacks.length; i < len; i++) {
          callback = callbacks[i];
          results.push(callback(data));
        }
        return results;
      } else {
        return console.log('Unhandled', name, data);
      }
    };

    WebsocketConnection.prototype.connect = function() {
      return this.client.connect((this.websocketUrl()) + "?version=2.0.0-alpha");
    };

    WebsocketConnection.prototype.disconnect = function(reason) {
      var ref;
      return (ref = this.connection) != null ? ref.close(reason != null ? reason : WebSocketConnection.CLOSE_REASON_NORMAL) : void 0;
    };

    WebsocketConnection.prototype.websocketUrl = function() {
      if (this.debug) {
        return 'ws://0.0.0.0:9292/';
      } else {
        return 'wss://valenciamgmt.net/messenger/';
      }
    };

    return WebsocketConnection;

  })();

  module.exports = WebsocketConnection;

}).call(this);
