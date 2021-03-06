(function() {
  var ipcRenderer, keytar, request, validateCredentials, validationFailed, validationSucceeded;

  request = require('request');

  keytar = require('keytar');

  ipcRenderer = require('electron').ipcRenderer;

  validationSucceeded = function(token) {
    keytar.setPassword('valenciamgmt.net', 'authToken', token);
    return ipcRenderer.send('authenticated');
  };

  validationFailed = function(error) {
    console.log(error);
    return document.getElementById('perform-authentication').value = 'Authenticate';
  };

  validateCredentials = function(username, password) {
    return request.post({
      headers: {
        'Content-Type': 'application/json'
      },
      url: 'http://asgard.dev/api/v1/authenticate',
      body: JSON.stringify({
        username: username,
        password: password
      })
    }, function(error, response, body) {
      if (error) {
        return validationFailed(error);
      }
      return validationSucceeded(JSON.parse(body).token);
    });
  };

  document.getElementById('authentication-form').onsubmit = function() {
    var password, username;
    document.getElementById('perform-authentication').value = 'Authenticating...';
    username = document.getElementById('username').value;
    password = document.getElementById('password').value;
    validateCredentials(username, password);
    return false;
  };

}).call(this);
