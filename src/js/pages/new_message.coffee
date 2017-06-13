users = JSON.parse(decodeURIComponent(window.location.hash[1...]))

document.getElementById('users')
  .innerText = (user.username for user in users).join(', ')
