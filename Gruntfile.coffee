module.exports = (grunt) ->
    # Project configuration
    grunt.initConfig {
        pkg: grunt.file.readJSON('package.json'),

        coffee: {
            compile: {
                options: {
                    bare: true
                },
                files: {
                    'src/core/circle.js': 'src/core/circle.coffee',
                    'src/core/curve.js': 'src/core/curve.coffee',
                    'src/core/plot.js': 'src/core/plot.coffee',
                    'src/core/plot_object.js': 'src/core/plot_object.coffee',
                    'src/core/line.js': 'src/core/line.coffee',
                    'src/core/point.js': 'src/core/point.coffee',
                    'src/view/view.js': 'src/view/view.coffee',
                }
            }
        },

        browserify: {
            dist: {
                files: {
                    'static/js/youclid.js': 'src/youclid.js'
                }
            }
        }
    }

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-browserify'
    #grunt.loadNpmTasks 'grunt-coffeeify'



