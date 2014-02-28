TestJumperLeap = require './test-jumper-leap'

module.exports =

  configDefaults:
    "locations": [
     'lib|spec'
     'app|spec'
    ]
    "spec-announcer": '-spec'

  activate: (state) ->
    atom.workspaceView.command "test-jumper:jump", => @jump()

  jump: ->
    leaper = new TestJumperLeap
    leaper.leap()
