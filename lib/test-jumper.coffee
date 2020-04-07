TestJumperLeap = require './test-jumper-leap'

module.exports =

  config:
    'spec_to_the_right':
      title: "Check this if you want opening a spec to pop open a panel to the right."
      type: 'boolean'
      default: 'false'
    'x-create-files':
      type: 'object'
      properties:
        'enabled':
          title: 'Create missing files'
          description: 'If an expected file is missing, it is automatically created.'
          type: 'boolean'
          default: false
        'source-template':
          title: 'Source file template'
          description: 'The default content of a generated source file. "%s" gets replaced by the file name.'
          type: 'string'
          default: '# %s\\n#\\n'
        'spec-template':
          title: 'Test file template'
          description: 'The default content of a generated test file. "%s" gets replaced by the file name.'
          type: 'string'
          default: '# Specification of %s\\n#\\n'


  activate: (state) ->
    atom.commands.add 'atom-text-editor',
      "test-jumper:jump", => @jump()

  jump: ->
    leaper = new TestJumperLeap
    leaper.leap()
