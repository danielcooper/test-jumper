TestJumperLeap = require './test-jumper-leap'

module.exports =

  configDefaults:
    'locations':
      type: 'array'
      default: [
         'lib|spec'
         'app|spec'
        ]
      items:
        type: 'string'
    'spec-announcer':
      type: 'string'
      default: '%s-spec'

  activate: (state) ->
    atom.workspaceView.command "test-jumper:jump", => @jump()

  jump: ->
    leaper = new TestJumperLeap
    leaper.leap()
