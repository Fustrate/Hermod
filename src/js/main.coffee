{ remote, ipcRenderer } = require 'electron'
{ Menu, MenuItem } = remote

localShortcut = remote.require('electron-localshortcut')

String.prototype.toTitleCase = ->
  @replace /\w\S*/g, (txt) ->
    txt[0].toUpperCase() + txt[1..(txt.length - 1)].toLowerCase()

class MainWindow
  displayedStatus: 'Offline'
  userList: []
  statuses: {}

  constructor: ->
    @window = remote.getCurrentWindow()

    @connectionIndicator = document.getElementById 'connection-indicator'
    @statusIndicator = document.getElementById 'status-indicator'

    @usersTab = document.getElementById 'tab-users'
    @messagesTab = document.getElementById 'tab-messages'

    @usersContent = document.getElementById 'content-users'
    @messagesContent = document.getElementById 'content-messages'

    ipcRenderer.on 'employees_list', (event, @userList) =>
      @refreshUserList()

    ipcRenderer.on 'employees_statuses', (event, @statuses) =>
      @refreshUserStatuses()

    ipcRenderer.on 'setDisplayedStatus', @setDisplayedStatus
    ipcRenderer.on 'setConnectionStatus', @setConnectionStatus

    @addMenus()

    @addEventListeners()

    localShortcut.register @window, 'Alt+A', @selectAll
    localShortcut.register @window, 'Alt+D', @deselectAll

  addEventListeners: =>
    @usersTab.addEventListener 'click', =>
      @usersTab.classList.toggle 'active', true
      @messagesTab.classList.toggle 'active', false

      @usersContent.classList.toggle 'active', true
      @messagesContent.classList.toggle 'active', false

    @messagesTab.addEventListener 'click', =>
      @usersTab.classList.toggle 'active', false
      @messagesTab.classList.toggle 'active', true

      @usersContent.classList.toggle 'active', false
      @messagesContent.classList.toggle 'active', true

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

    @statusMenu.popup remote.getCurrentWindow()

  doNothing: ->

  # TODO: Preserve selected users
  refreshUserList: =>
    for role in @userList
      [group, users] = @renderRole role
      @usersContent.appendChild group
      @usersContent.appendChild users

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
