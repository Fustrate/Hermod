http = require 'http'
keytar = require 'keytar'

document.getElementById('authentication-form').onClick = (e) ->
  alert('wow')

validateCredentials = (username, password, callback, errback) ->
  options =
    protocol: 'https'
    hostname: 'valenciamgmt.net'
    port: 443
    path: '/api/v1/authenticate',
    method: 'POST'
    headers:
      'Content-Type': 'application/json'

  req = http.request options, (res) ->
    console.log "Status: #{res.statusCode}"
    console.log "Headers: #{JSON.stringify(res.headers)}"
    res.setEncoding 'utf8'
    res.on 'data', (body) ->
      console.log 'Body: ' + body

  req.on 'error', errback

  # write data to request body
  # req.write('{"string": result}');  ///RESULT HERE IS A JSON

  req.write JSON.stringify({ username: username, password: password })

  req.end()
