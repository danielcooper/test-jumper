TestJumperLeap = require './test-jumper-leap'

module.exports =

  config:
    'locations':
      title: 'Source and Test Locations'
      description: 'A comma-separated list of source-/test-directory pairs. Each pair is separated by a pipe (|) symbol.'
      type: 'array'
      default: [
         'lib|spec'
         'app|spec'
        ]
      items:
        type: 'string'
    'spec-announcer':
      title: 'Test-Filename'
      description: 'The name of the testfile, whereas "%s" gets replaced by the original filename.'
      type: 'string'
      default: '%s-spec'


  activate: (state) ->
    atom.commands.add 'atom-text-editor',
      "test-jumper:jump", => @jump()

  jump: ->
    leaper = new TestJumperLeap
    leaper.leap()
