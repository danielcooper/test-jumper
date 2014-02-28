TestJumper = require '../lib/test-jumper'
TestJumperLeap = require '../lib/test-jumper-leap'
{WorkspaceView} = require 'atom'


# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "TestJumperLeap", ->
  activationPromise = null

  beforeEach =>
    atom.workspaceView = new WorkspaceView
    @leaper = new TestJumperLeap


  it "is able to get the placement target for a bit of code", =>
    spyOn(@leaper, "getCurrentFilePath").andCallFake ->
      'lib/object.js.coffee'

    expect(@leaper.getMovementTarget()[0][0]).toBe('lib/object.js.coffee')


  it "knows if the current file is a spec", =>

    spyOn(@leaper, "getCurrentFilePath").andCallFake ->
      '/object-spec.js.coffee'

    expect(@leaper.currentPathIsSpec()).toBe(true);


  it "knows if the current file is nt a spec", =>

    spyOn(@leaper, "getCurrentFilePath").andCallFake ->
      '/object.js.coffee'

    expect(@leaper.currentPathIsSpec()).toBe(false);
