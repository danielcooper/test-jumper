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
