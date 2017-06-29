(function() {
  var MainWindow, Menu, MenuItem, ipcRenderer, localShortcut, ref, remote,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  ref = require('electron'), remote = ref.remote, ipcRenderer = ref.ipcRenderer;

  Menu = remote.Menu, MenuItem = remote.MenuItem;

  localShortcut = remote.require('electron-localshortcut');

  String.prototype.toTitleCase = function() {
    return this.replace(/\w\S*/g, function(txt) {
      return txt[0].toUpperCase() + txt.slice(1, +(txt.length - 1) + 1 || 9e9).toLowerCase();
    });
  };

  MainWindow = (function() {
    MainWindow.prototype.displayedStatus = 'Offline';

    MainWindow.prototype.users = [];

    MainWindow.prototype.statuses = {};

    function MainWindow() {
      this.newMessage = bind(this.newMessage, this);
      this.setDisplayedStatus = bind(this.setDisplayedStatus, this);
      this.setConnectionStatus = bind(this.setConnectionStatus, this);
      this.renderUserItem = bind(this.renderUserItem, this);
      this.renderRole = bind(this.renderRole, this);
      this.refreshUserStatuses = bind(this.refreshUserStatuses, this);
      this.refreshUsers = bind(this.refreshUsers, this);
      this.openStatusMenu = bind(this.openStatusMenu, this);
      this.addMenus = bind(this.addMenus, this);
      this.openMessagesTab = bind(this.openMessagesTab, this);
      this.openUsersTab = bind(this.openUsersTab, this);
      this.addEventListeners = bind(this.addEventListeners, this);
      this.addIPCListeners = bind(this.addIPCListeners, this);
      this.window = remote.getCurrentWindow();
      this.connectionIndicator = document.getElementById('connection-indicator');
      this.statusIndicator = document.getElementById('status-indicator');
      this.tabs = {
        users: {
          button: document.getElementById('tab-users'),
          content: document.getElementById('content-users')
        },
        messages: {
          button: document.getElementById('tab-messages'),
          content: document.getElementById('content-messages')
        }
      };
      this.userList = document.getElementById('user-list');
      this.buttons = {
        new_message: document.getElementById('new-message')
      };
      this.addMenus();
      this.addIPCListeners();
      this.addEventListeners();
    }

    MainWindow.prototype.addIPCListeners = function() {
      ipcRenderer.on('employees_list', this.refreshUsers);
      ipcRenderer.on('employees_statuses', this.refreshUserStatuses);
      ipcRenderer.on('setDisplayedStatus', this.setDisplayedStatus);
      return ipcRenderer.on('setConnectionStatus', this.setConnectionStatus);
    };

    MainWindow.prototype.addEventListeners = function() {
      this.tabs.users.button.addEventListener('click', this.openUsersTab);
      this.tabs.messages.button.addEventListener('click', this.openMessagesTab);
      this.buttons.new_message.addEventListener('click', this.newMessage);
      localShortcut.register(this.window, 'Alt+A', this.selectAll);
      localShortcut.register(this.window, 'Alt+D', this.deselectAll);
      localShortcut.register(this.window, 'Alt+N', this.newMessage);
      return localShortcut.register(this.window, 'Alt+I', this.about);
    };

    MainWindow.prototype.openUsersTab = function() {
      this.tabs.users.button.classList.toggle('active', true);
      this.tabs.messages.button.classList.toggle('active', false);
      this.tabs.users.content.classList.toggle('active', true);
      return this.tabs.messages.content.classList.toggle('active', false);
    };

    MainWindow.prototype.openMessagesTab = function() {
      this.tabs.users.button.classList.toggle('active', false);
      this.tabs.messages.button.classList.toggle('active', true);
      this.tabs.users.content.classList.toggle('active', false);
      return this.tabs.messages.content.classList.toggle('active', true);
    };

    MainWindow.prototype.addMenus = function() {
      this.statusMenu = new Menu;
      this.statusMenu.append(new MenuItem({
        label: 'Online',
        click: this.doNothing
      }));
      this.statusMenu.append(new MenuItem({
        label: 'Do Not Disturb',
        click: this.doNothing
      }));
      this.statusMenu.append(new MenuItem({
        label: 'Out of Office',
        click: this.doNothing
      }));
      this.statusIndicator.addEventListener('click', this.openStatusMenu, false);
      return this.statusIndicator.addEventListener('contextmenu', this.openStatusMenu, false);
    };

    MainWindow.prototype.openStatusMenu = function(e) {
      var displayed, i, item, len, ref1;
      e.preventDefault();
      displayed = this.displayedStatus.toLowerCase();
      ref1 = this.statusMenu.items;
      for (i = 0, len = ref1.length; i < len; i++) {
        item = ref1[i];
        item.visible = item.label.toLowerCase() !== displayed;
      }
      return this.statusMenu.popup(this.window);
    };

    MainWindow.prototype.doNothing = function(e) {
      return console.log(e);
    };

    MainWindow.prototype.refreshUsers = function(event, users1) {
      var group, i, len, ref1, ref2, results, role, users;
      this.users = users1;
      ref1 = this.users;
      results = [];
      for (i = 0, len = ref1.length; i < len; i++) {
        role = ref1[i];
        ref2 = this.renderRole(role), group = ref2[0], users = ref2[1];
        this.userList.appendChild(group);
        results.push(this.userList.appendChild(users));
      }
      return results;
    };

    MainWindow.prototype.refreshUserStatuses = function(event, statuses) {
      var classes, element, i, len, ref1, results, role, user;
      this.statuses = statuses;
      ref1 = this.users;
      results = [];
      for (i = 0, len = ref1.length; i < len; i++) {
        role = ref1[i];
        results.push((function() {
          var j, len1, ref2, ref3, results1;
          ref2 = role.employees;
          results1 = [];
          for (j = 0, len1 = ref2.length; j < len1; j++) {
            user = ref2[j];
            element = document.getElementById("user_" + user.id);
            classes = [(ref3 = this.statuses[user.id]) != null ? ref3 : 'offline'];
            if (element.classList.contains('selected')) {
              classes.push('selected');
            }
            results1.push(element.className = classes.join(' '));
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    MainWindow.prototype.renderRole = function(role) {
      var group, i, len, ref1, user, usersList;
      role.employees.sort(function(a, b) {
        if (a.username < b.username) {
          return -1;
        } else {
          return 1;
        }
      });
      group = document.createElement('div');
      group.classList.add('group');
      group.appendChild(document.createTextNode(role.title));
      group.addEventListener('click', this.clickedGroup);
      group.addEventListener('dblclick', this.dblClickedGroup);
      usersList = document.createElement('div');
      usersList.className = 'users-list';
      ref1 = role.employees;
      for (i = 0, len = ref1.length; i < len; i++) {
        user = ref1[i];
        usersList.appendChild(this.renderUserItem(user));
      }
      return [group, usersList];
    };

    MainWindow.prototype.renderUserItem = function(user) {
      var element, ref1, status;
      status = (ref1 = this.statuses[user.id]) != null ? ref1 : 'offline';
      element = document.createElement('span');
      element.setAttribute('id', "user_" + user.id);
      element.user = user;
      element.classList.add('user', status);
      element.appendChild(document.createTextNode(user.username));
      element.addEventListener('click', this.clickedUser);
      element.addEventListener('dblclick', this.doubleClickedUser);
      return element;
    };

    MainWindow.prototype.setConnectionStatus = function(event, connectionStatus) {
      this.connectionStatus = connectionStatus;
      this.connectionIndicator.innerText = this.connectionStatus.toTitleCase();
      return this.connectionIndicator.className = this.connectionStatus.toLowerCase();
    };

    MainWindow.prototype.setDisplayedStatus = function(event, displayedStatus) {
      this.displayedStatus = displayedStatus;
      this.statusIndicator.innerText = this.displayedStatus.toTitleCase();
      return this.statusIndicator.className = this.displayedStatus.toLowerCase();
    };

    MainWindow.prototype.selectAll = function() {
      var i, len, ref1, results, user;
      ref1 = document.getElementsByClassName('user');
      results = [];
      for (i = 0, len = ref1.length; i < len; i++) {
        user = ref1[i];
        results.push(user.classList.toggle('selected', true));
      }
      return results;
    };

    MainWindow.prototype.deselectAll = function() {
      var i, len, ref1, results, user;
      ref1 = document.getElementsByClassName('user');
      results = [];
      for (i = 0, len = ref1.length; i < len; i++) {
        user = ref1[i];
        results.push(user.classList.toggle('selected', false));
      }
      return results;
    };

    MainWindow.prototype.newMessage = function() {
      var i, len, ref1, selectedUsers, user;
      selectedUsers = [];
      ref1 = document.getElementsByClassName('user');
      for (i = 0, len = ref1.length; i < len; i++) {
        user = ref1[i];
        if (user.classList.contains('selected')) {
          selectedUsers.push({
            id: user.user.id,
            username: user.user.username
          });
        }
      }
      ipcRenderer.send('new_message', JSON.stringify(selectedUsers));
      return this.buttons.new_message.blur();
    };

    MainWindow.prototype.about = function() {
      return ipcRenderer.send('about');
    };

    MainWindow.prototype.clickedUser = function(event) {
      return event.target.classList.toggle('selected');
    };

    MainWindow.prototype.doubleClickedUser = function(event) {};

    MainWindow.prototype.clickedGroup = function(event) {
      var child, groupUsers, i, len, ref1, results, selected, unselected;
      groupUsers = event.target.nextElementSibling;
      selected = groupUsers.getElementsByClassName('selected');
      unselected = groupUsers.children.length !== selected.length;
      ref1 = groupUsers.children;
      results = [];
      for (i = 0, len = ref1.length; i < len; i++) {
        child = ref1[i];
        results.push(child.classList.toggle('selected', unselected));
      }
      return results;
    };

    MainWindow.prototype.doubleClickedGroup = function(event) {};

    return MainWindow;

  })();

  new MainWindow;

}).call(this);
