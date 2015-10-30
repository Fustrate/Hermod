http = require 'http'
keytar = require 'keytar'

storedUsername = keytar
storedPassword = keytar.getPassword('serviceName', 'username')

# if we have stored credentials
#   if we can log in with them
#     open the main window
#   else
#     prompt for new credentials
# else
#   prompt for new credentials

promptForCredentials = ->

# options =
#   protocol: 'https'
#   hostname: 'valenciamgmt.net'
#   port: 443
#   path: '/api/v1/authenticate',
#   method: 'POST'
#   headers:
#     'Content-Type': 'application/json'
#
# req = http.request options, (res) ->
#   console.log "Status: #{res.statusCode}"
#   console.log "Headers: #{JSON.stringify(res.headers)}"
#   res.setEncoding 'utf8'
#   res.on 'data', (body) ->
#     console.log 'Body: ' + body
#
# req.on 'error', (e) ->
#   console.log('problem with request: ' + e.message)
#
# # write data to request body
# # req.write('{"string": result}');  ///RESULT HERE IS A JSON
#
# username = 'shoffman'
# password = 'incorrect'
#
# req.write JSON.stringify({ username: username, password: password })
#
# req.end()
