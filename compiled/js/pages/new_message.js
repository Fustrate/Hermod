// Generated by CoffeeScript 1.12.6
(function() {
  var user, users;

  users = JSON.parse(decodeURIComponent(window.location.hash.slice(1)));

  document.getElementById('users').innerText = ((function() {
    var i, len, results;
    results = [];
    for (i = 0, len = users.length; i < len; i++) {
      user = users[i];
      results.push(user.username);
    }
    return results;
  })()).join(', ');

}).call(this);