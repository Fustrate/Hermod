{ ipcRenderer } = require 'electron'

String.prototype.toTitleCase = ->
  @replace /\w\S*/g, (txt) ->
    txt[0].toUpperCase() + txt[1..(txt.length - 1)].toLowerCase()

class MainWindow
  displayedStatus: 'Offline'
  userList: []
  statuses: {}

  constructor: ->
    @contentArea = document.getElementById 'content'
    @connectionIndicator = document.getElementById 'connection-indicator'
    @statusIndicator = document.getElementById 'status-indicator'

    ipcRenderer.on 'employees_list', (event, @userList) =>
      @refreshUserList()

    ipcRenderer.on 'employees_statuses', (event, @statuses) =>
      @refreshUserStatuses()

    ipcRenderer.on 'setDisplayedStatus', @setDisplayedStatus
    ipcRenderer.on 'setConnectionStatus', @setConnectionStatus

  # TODO: Preserve selected users
  refreshUserList: =>
    for role in @userList
      [group, users] = @renderRole role
      @contentArea.appendChild group
      @contentArea.appendChild users

  refreshUserStatuses: =>
    # Don't try to change statuses when the app first starts
    return unless @userList

    for role in @userList
      for user in role.employees
        element = document.getElementById("user_#{user.id}")

        classes = [@statuses[user.id] ? 'offline']
        classes.push 'selected' if element.classList.contains 'selected'

        # Let's not worry about toggling so many classes
        element.className = classes.join(' ')

  renderRole: (role) =>
    role.employees.sort (a, b) ->
      if a.username < b.username then -1 else 1

    group = document.createElement('div')
    group.className = 'group'
    group.appendChild document.createTextNode(role.title)
    group.addEventListener 'click', @clickedGroup
    group.addEventListener 'dblclick', @dblClickedGroup

    usersList = document.createElement('div')
    usersList.className = 'users-list'

    for user in role.employees
      usersList.appendChild @renderUserItem(user)

    [group, usersList]

  renderUserItem: (user) =>
    status = @statuses[user.id] ? 'offline'

    element = document.createElement 'span'
    element.setAttribute('id', "user_#{user.id}")
    element.className = status
    element.appendChild document.createTextNode(user.username)

    element.addEventListener 'click', @clickedUser
    element.addEventListener 'dblclick', @doubleClickedUser

    element

  setConnectionStatus: (event, @connectionStatus) =>
    @connectionIndicator.innerText = @connectionStatus.toTitleCase()
    @connectionIndicator.className = @connectionStatus.toLowerCase()

  setDisplayedStatus: (event, @displayedStatus) =>
    @statusIndicator.innerText = @displayedStatus.toTitleCase()
    @statusIndicator.className = @displayedStatus.toLowerCase()

  clickedUser: (event) ->
    event.target.classList.toggle 'selected'

  doubleClickedUser: (event) ->
    # console.log 'double user', event

  clickedGroup: (event) ->
    groupUsers = event.target.nextElementSibling
    selected = groupUsers.getElementsByClassName('selected')

    unselected = groupUsers.children.length isnt selected.length

    for child in groupUsers.children
      child.classList.toggle 'selected', unselected

  doubleClickedGroup: (event) ->
    # console.log 'double group', event

new MainWindow
