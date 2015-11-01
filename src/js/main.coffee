ipc = require 'ipc'

contentArea = document.getElementById('content')
userList = []
statuses = {}

# TODO: Preserve selected users
refreshUserList = ->
  contentArea.innerHTML = (renderRole role for role in userList).join('')

renderRole = (role) ->
  users = (renderUserItem user for user in role.users).join('')

  """
  <div class="group">#{role.title}</div>
  <div class="users-list">#{users}</div>
  """

renderUserItem = (user) ->
  status = statuses[user.id] ? 'unknown'

  """
  <span class="#{status}">
    #{user.username}
  </span>
  """

ipc.on 'users.list', (newUserList) ->
  userList = newUserList
  refreshUserList()

ipc.on 'users.statuses', (newStatuses) ->
  statuses = newStatuses
  refreshUserList()
