{ipcMain} = require 'electron'

String.prototype.toTitleCase = ->
  @replace /\w\S*/g, (txt) ->
    txt[0].toUpperCase() + txt[1..txt.length - 1].toLowerCase()

class MainWindow
  displayedStatus: 'Offline'
  userList: []
  statuses: {}

  constructor: ->
    @contentArea = document.getElementById 'content'
    @connectionIndicator = document.getElementById 'connection-indicator'
    @statusIndicator = document.getElementById 'status-indicator'

    ipcMain.on 'users.list', (@userList) =>
      @refreshUserList()

    ipcMain.on 'users.statuses', (@statuses) =>
      @refreshUserList()

    ipcMain.on 'setDisplayedStatus', @setDisplayedStatus
    ipcMain.on 'setConnectionStatus', @setConnectionStatus

  # TODO: Preserve selected users
  refreshUserList: =>
    @contentArea.innerHTML = (@renderRole role for role in @userList).join('')

  renderRole: (role) =>
    users = (@renderUserItem user for user in role.users).join('')

    """
    <div class="group">#{role.title}</div>
    <div class="users-list">#{users}</div>
    """

  renderUserItem: (user) =>
    status = @statuses[user.id] ? 'offline'

    """
    <span class="#{status}">
      #{user.username}
    </span>
    """

  setConnectionStatus: (@connectionStatus) =>
    @connectionIndicator.innerText = @connectionStatus.toTitleCase()
    @connectionIndicator.className = @connectionStatus.toLowerCase()

  setDisplayedStatus: (@displayedStatus) =>
    @statusIndicator.innerText = @displayedStatus.toTitleCase()
    @statusIndicator.className = @displayedStatus.toLowerCase()

new MainWindow
