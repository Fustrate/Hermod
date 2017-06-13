about = { win: null }

{ BrowserWindow } = require('electron')

about.init = ->
  return about.win.show() if about.win

  about.win = new BrowserWindow
    backgroundColor: '#ECECEC'
    center: true
    fullscreen: false
    height: 170
    # icon: getIconPath()
    maximizable: false
    minimizable: false
    resizable: false
    show: false
    skipTaskbar: true
    # title: 'About ' + config.APP_WINDOW_TITLE
    useContentSize: true
    width: 300

  about.win.loadURL "file://#{__dirname}/../../html/about.html"

  # No menu on the About window
  about.win.setMenu null

  about.win.once 'ready-to-show', about.win.show

  about.win.once 'closed', ->
    about.win = null

module.exports = about
