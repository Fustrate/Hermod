{ remote, ipcRenderer } = require 'electron'
{ Menu, MenuItem } = remote

localShortcut = remote.require('electron-localshortcut')

String.prototype.toTitleCase = ->
  @replace /\w\S*/g, (txt) ->
    txt[0].toUpperCase() + txt[1..(txt.length - 1)].toLowerCase()

class MainWindow
  displayedStatus: 'Offline'
  users: []
  statuses: {}

  constructor: ->
    @window = remote.getCurrentWindow()

    @connectionIndicator = document.getElementById 'connection-indicator'
    @statusIndicator = document.getElementById 'status-indicator'

    @tabs =
      users:
        button: document.getElementById 'tab-users'
        content: document.getElementById 'content-users'
      messages:
        button: document.getElementById 'tab-messages'
        content: document.getElementById 'content-messages'

    @userList = document.getElementById 'user-list'

    @buttons =
      new_message: document.getElementById('new-message')

    @addMenus()
    @addIPCListeners()
    @addEventListeners()

  addIPCListeners: =>
    ipcRenderer.on 'employees_list', @refreshUsers
    ipcRenderer.on 'employees_statuses', @refreshUserStatuses
    ipcRenderer.on 'setDisplayedStatus', @setDisplayedStatus
    ipcRenderer.on 'setConnectionStatus', @setConnectionStatus

  addEventListeners: =>
    @tabs.users.button.addEventListener 'click', @openUsersTab
    @tabs.messages.button.addEventListener 'click', @openMessagesTab

    @buttons.new_message.addEventListener 'click', @newMessage

    localShortcut.register @window, 'Alt+A', @selectAll
    localShortcut.register @window, 'Alt+D', @deselectAll
    localShortcut.register @window, 'Alt+N', @newMessage
    localShortcut.register @window, 'Alt+I', @about

  openUsersTab: =>
    @tabs.users.button.classList.toggle 'active', true
    @tabs.messages.button.classList.toggle 'active', false

    @tabs.users.content.classList.toggle 'active', true
    @tabs.messages.content.classList.toggle 'active', false

  openMessagesTab: =>
    @tabs.users.button.classList.toggle 'active', false
    @tabs.messages.button.classList.toggle 'active', true

    @tabs.users.content.classList.toggle 'active', false
    @tabs.messages.content.classList.toggle 'active', true

  addMenus: =>
    @statusMenu = new Menu

    @statusMenu.append new MenuItem(label: 'Online', click: @doNothing)
    @statusMenu.append new MenuItem(label: 'Do Not Disturb', click: @doNothing)
    @statusMenu.append new MenuItem(label: 'Out of Office', click: @doNothing)

    @statusIndicator.addEventListener 'click', @openStatusMenu, false
    @statusIndicator.addEventListener 'contextmenu', @openStatusMenu, false

  openStatusMenu: (e) =>
    e.preventDefault()

    displayed = @displayedStatus.toLowerCase()

    for item in @statusMenu.items
      item.visible = item.label.toLowerCase() isnt displayed

    @statusMenu.popup @window

  doNothing: (e) ->
    console.log e

  # TODO: Preserve selected users if a user is added or removed
  refreshUsers: (event, @users) =>
    for role in @users
      [group, users] = @renderRole role
      @userList.appendChild group
      @userList.appendChild users

  refreshUserStatuses: (event, @statuses) =>
    for role in @users
      for user in role.employees
        element = document.getElementById("user_#{user.id}")

        classes = [@statuses[user.id] ? 'offline']
        classes.push 'selected' if element.classList.contains 'selected'

        # Let's not worry about toggling so many potential classes
        element.className = classes.join(' ')

  renderRole: (role) =>
    role.employees.sort (a, b) ->
      if a.username < b.username then -1 else 1

    group = document.createElement('div')
    group.classList.add 'group'
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
    element.user = user
    element.classList.add 'user', status
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

  selectAll: ->
    for user in document.getElementsByClassName('user')
      user.classList.toggle 'selected', true

  deselectAll: ->
    for user in document.getElementsByClassName('user')
      user.classList.toggle 'selected', false

  newMessage: =>
    selectedUsers = []

    for user in document.getElementsByClassName('user')
      if user.classList.contains 'selected'
        selectedUsers.push { id: user.user.id, username: user.user.username }

    ipcRenderer.send 'new_message', JSON.stringify(selectedUsers)

    @buttons.new_message.blur()

  about: ->
    ipcRenderer.send 'about'

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
