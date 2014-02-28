TestJumperView = require './test-jumper-view'
TestJumperLeap = require './test-jumper-leap'

module.exports =
  testJumperView: null

  configDefaults:
    "locations": [
     'lib|spec'
     'app|spec'
    ]
    "spec-announcer": '-spec'

  activate: (state) ->
    atom.workspaceView.command "test-jumper:jump", => @jump()

  deactivate: ->
    @testJumperView.destroy()

  serialize: ->
    testJumperViewState: @testJumperView.serialize()

  jump: ->
    leaper = new TestJumperLeap
    leaper.leap()

  jumpToTest: ->


  jumpToFile: ->
