TestJumper = require '../lib/test-jumper'
TestJumperLeap = require '../lib/test-jumper-leap'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "TestJumperLeap", ->
  activationPromise = null

  beforeEach =>
    spyOn(atom.config, "get").andCallFake (prop) ->
      prop = prop.replace('test-jumper.','')

      if prop of TestJumper.config and 'default' of TestJumper.config[prop]
        TestJumper.config[prop].default

      else
        atom.config[prop]

    @leaper = new TestJumperLeap


  it "is able to get the placement target for a bit of code", =>
    expect(@leaper.getMovementTargetForFilePath('lib/object.js.coffee')[0][0]).toBe('lib/object.js.coffee')

  it "knows if the current file is a spec", =>
    expect(@leaper.filenameIsSpec('/object-spec.js.coffee')).toBe(true);


  it "knows if the current file is not a spec", =>
    expect(@leaper.filenameIsSpec('/object.js.coffee')).toBe(false);

  describe '@template_replace', ->
    it "replaces a coffescript match", ->
      r = /(.*)-spec.coffee/
      newname = new TestJumperLeap().template_replace(r, "{}.coffee", "code-spec.coffee")
      expect(newname).toBe('code.coffee')
