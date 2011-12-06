muffin = require 'muffin'
glob   = require 'glob'
{exec} = require 'child_process'

option '-w', '--watch', 'continue to watch the files and rebuild them when they change'
option '-c', '--commit', 'operate on the git index instead of the working tree'
option '-d', '--compare', 'compare to git refs (stat task only)'

# Path to binary ragel from https://github.com/dominicmarks/ragel-js
# Need this because vanilla ragel doesn't compile to JS
RAGEL_PATH = "~/Code/ragel-js/ragel-svn/ragel/ragel"

compileLanguage = (file, destination) ->
  [child, promise] = muffin.exec("language -g #{file} > #{destination}")
  promise.then(-> console.log "Compiled language #{file} successfully.")

compileRagel = (file, destination) ->
  cmd = "#{RAGEL_PATH} -E -o #{destination} #{file}"
  [child, promise] = muffin.exec(cmd)
  promise.then(-> console.log "Compiled ragel file #{file} successfully.")

task 'build', 'compile search_query', (options) ->
  muffin.run
    files: './src/**/*'
    options: options
    map:
      'src/(.+).coffee'              : (matches) -> muffin.compileScript(matches[0], "lib/#{matches[1]}.js", options)
      'src/language/search_query.rl' : (matches) -> compileRagel(matches[0], "lib/rl_basic_parser.js")
      'src/language/search_query.language'   : (matches) -> compileLanguage(matches[0], "lib/lg_basic_parser.js")

task 'build:language_visualizer', 'compile the PEG into the language visualizer', (options) ->
  muffin.run
    files: './src/**/*'
    options: options
    map:
      'src/language/(.+).language'   : (matches) ->
        [child, promise] = muffin.exec "language -g #{matches[0]} --browser=Parser > ~/Code/language/LanguageVisualizer/parser.js"
        child.stdin.end()
        promise.then(-> console.log "Compiled language #{matches[0]} to LanguageVisualizer destination.")

task 'test', 'run the test suite', (options) ->
  runner = (require 'nodeunit').reporters.default

  muffin.run
    files: ['./src/**/*.coffee', './lib/**/*.js', './test/**/*.coffee']
    options: options
    map:
     'src/(.+).coffee'      : (matches) ->
     'test/(.+)_test.coffee'   : (matches) ->
     'test/test_helper.coffee' : (matches) ->
    after: ->
      tests = glob.globSync('./test/**/*_test.coffee')
      runner.run tests

task 'stats', 'print source code stats', (options) ->
  muffin.statFiles(glob.globSync('./src/**/*').concat(glob.globSync('./lib/**/*')), options)

task 'doc', 'autogenerate docco anotated source', (options) ->
  muffin.run
    files: './src/**/*'
    options: options
    map:
      'src/search_query_parser.coffee'       : (matches) -> muffin.doccoFile(matches[0], options)

