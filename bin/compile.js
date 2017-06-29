const os = require('os')
const path = require('path')
const fs = require('fs')
const exec = require('child_process').execSync
// const rimraf = require('rimraf')
const mkdirp = require('mkdirp')
const coffee = require('coffeescript')

var platform = os.platform()

function copyFolder(folder) {
  if (platform == 'win32') {
    exec('xcopy src\\' + folder + ' compiled\\' + folder)
  } else if (platform == 'osx') {
    exec('cp -R src/' + folder + ' compiled')
  }
}

function walk(dir, callback) {
	fs.readdir(dir, function(err, files) {
		if (err) throw err;

		files.forEach(function(file) {
			var filepath = path.join(dir, file);

			fs.stat(filepath, function(err,stats) {
				if (stats.isDirectory()) {
					walk(filepath, callback);
				} else if (stats.isFile()) {
					callback(filepath, stats);
				}
			});
		});
	});
}

var compile = {
  all: function(){
    compile.css()
    compile.js()
    compile.html()
    compile.fonts()
  },
  css: function() {
    mkdirp('compiled/css', function() {
      exec('sass -Cq --update src/css:compiled/css --sourcemap=none')
    })
  },
  js: function() {
    mkdirp('compiled/js', function() {
      walk('src/js', function(input) {
        var output = input.replace('.coffee', '.js').replace('src', 'compiled')

        mkdirp(path.dirname(output), function() {
          fs.readFile(input, 'utf8', function(err, data) {
            fs.writeFile(output, coffee.compile(data), function(){})
          })
        })
      })
    })
  },
  html: function() {
    mkdirp('compiled/html', function() {
      copyFolder('html')
    })
  },
  fonts: function() {
    mkdirp('compiled/fonts', function() {
      copyFolder('fonts')
    })
  }
}

compile.all()
