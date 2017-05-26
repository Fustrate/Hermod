request = require 'request'
keytar = require 'keytar'
{ipcMain} = require 'electron'

validationSucceeded = (data) ->
  keytar.addPassword 'valenciamgmt.net', 'authToken', data.token
  ipcMain.sendSync('authenticated')

validationFailed = (error) ->
  console.log error
  document.getElementById('perform-authentication').value = 'Authenticate'

validateCredentials = (username, password) ->
  request.post
    headers:
      'Content-Type': 'application/json'
    url: 'http://asgard.dev/api/v1/authenticate'
    body: JSON.stringify({ username: username, password: password })
    (error, response, body) ->
      return validationFailed(error) if error

      validationSucceeded JSON.parse body

document.getElementById('authentication-form').onsubmit = ->
  document.getElementById('perform-authentication').value = 'Authenticating...'

  username = document.getElementById('username').value
  password = document.getElementById('password').value

  validateCredentials username, password

  false
