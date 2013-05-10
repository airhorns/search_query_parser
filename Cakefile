muffin     = require 'muffin'
glob       = require 'glob'
q          = require 'q'
{exec}     = require 'child_process'

option '-w', '--watch', 'continue to watch the files and rebuild them when they change'
option '-c', '--commit', 'operate on the git index instead of the working tree'

compileLanguage = (file, destination) ->
  [child, promise] = muffin.exec("./node_modules/language/bin/language -g #{file} > #{destination}")
  promise.then(-> console.log "Compiled language #{file} successfully.")

compileRagel = (file, destination) ->
  cmd = "#{RAGEL_PATH} -E -o #{destination} #{file}"
  [child, promise] = muffin.exec(cmd)
  promise.then(-> console.log "Compiled ragel file #{file} successfully.")

wrapWithExports = (source) ->
  "(function(){var module = {exports: {}}; var exports = module.exports; #{source}; return module.exports;})()"

task 'build', 'compile search_query', (options) ->
  muffin.run
    files: './src/**/*'
    options: options
    map:
      'src/(.+).coffee'              : (matches) -> muffin.compileScript(matches[0], "lib/#{matches[1]}.js", options)
      'src/search_query.rl'          : (matches) -> compileRagel(matches[0], "lib/rl_basic_parser.js")
      'src/search_query.language'    : (matches) -> compileLanguage(matches[0], "lib/basic_parser.js")
    after: ->
      distDestination = "lib/dist/search_query_parser.js"
      basic = muffin.readFile "lib/basic_parser.js", options
      augmented = muffin.readFile 'lib/search_query_parser.js', options
      q.all([basic, augmented]).spread (basicSource, augmentedSource) ->
        basicSource = wrapWithExports(basicSource)
        augmentedSource = wrapWithExports(augmentedSource)
        augmentedSource = augmentedSource.replace "require('./basic_parser')", basicSource
        augmentedSource = "window.SearchQueryParser = #{augmentedSource};"
        muffin.writeFile(distDestination, augmentedSource).then ->
          muffin.notify(distDestination, "Compiled and concatenated #{distDestination}.")

task 'build:language_visualizer', 'compile the PEG into the language visualizer', (options) ->
  muffin.run
    files: './src/**/*'
    options: options
    map:
      'src/(.+).language'   : (matches) ->
        [child, promise] = muffin.exec "./node_modules/language/bin/language -g #{matches[0]} --browser=Parser > ~/Code/language/LanguageVisualizer/parser.js"
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
      tests = glob.sync('./test/**/*_test.coffee')
      runner.run tests
