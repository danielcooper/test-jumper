#_ = require 'underscore'
FS = require('fs');

module.exports =
  class TestJumperLeap

    constructor: ->

    getCurrentFilePath: ->
      atom.project.relativize(atom.workspace.activePaneItem.getUri())

    currentPathIsSpec: ->
      /spec\./.test(@getCurrentFilePath())

    leap: ->
      return unless atom.workspace.getActiveEditor()

      for target in @getMovementTarget()
        filename = /(.*?)\.+/.exec(atom.workspace.activePaneItem.getTitle())[1]
        if @currentPathIsSpec()
          target_filename = filename.replace atom.config.get('test-jumper.spec-announcer'), ''
        else
          target_filename = filename + atom.config.get('test-jumper.spec-announcer')

        t = target[1]
        openthis = t.replace(filename, target_filename)
        openthis = atom.project.getRootDirectory().path + "/" + openthis

        if FS.existsSync openthis
            atom.workspace.open(openthis)


    getMovementTarget: ->
      replace_targets = @getMovementRules().filter (r) =>
        (new RegExp("^#{r[0]}")).test(@getCurrentFilePath())

      replace_targets.map (target) =>
        [@getCurrentFilePath(), @getCurrentFilePath().replace (new RegExp("^#{target[0]}")), target[1]]

    getMovementRules: ->
      targets = atom.config.get('test-jumper.locations').map (location) ->
        location.split('|')

      if @currentPathIsSpec()
        return targets.map (t) ->
          [t[1],t[0]]
      else
        return targets
