(function() {
  var appConfig, arch, electron, getConfigPath, path;

  appConfig = require('application-config')('Hermod');

  path = require('path');

  electron = require('electron');

  arch = require('arch');

  module.exports = {
    APP_COPYRIGHT: 'Copyright © 2017 Valencia Management Group',
    APP_NAME: 'Hermod',
    APP_TEAM: 'Valencia Management Group',
    APP_VERSION: require('../package.json').version,
    CONFIG_PATH: path.dirname(appConfig.filePath),
    OS_SYSARCH: (arch() === 'x64' ? 'x64' : 'ia32'),
    WINDOW_ABOUT: 'file://' + path.join(__dirname, '..', 'html', 'about.html'),
    WINDOW_MAIN: 'file://' + path.join(__dirname, '..', 'html', 'main.html')
  };

  getConfigPath = function() {
    return path.dirname(appConfig.filePath);
  };

}).call(this);
