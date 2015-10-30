request = require 'request'
keytar = require 'keytar'

document.getElementById('authentication-form').onsubmit = ->
  document.getElementById('perform-authentication').value = 'Authenticating...'

  username = document.getElementById('username').value
  password = document.getElementById('password').value

  validateCredentials username, password, validationSucceeded, validationFailed

  false

validationSucceeded = (data) ->
  console.log 'yay!'
  console.log data
validationFailed = (error) ->
  console.log 'oh no :('
  console.log error
  document.getElementById('perform-authentication').value = 'Authenticate'

validateCredentials = (username, password, callback, errback) ->
  request.post
    headers:
      'Content-Type': 'application/json'
    url: 'http://panel.dev/api/v1/authenticate'
    body: JSON.stringify({ username: username, password: password })
    (error, response, body) ->
      return errback(error) if error

      callback JSON.parse body
