#_ = require 'underscore'
FS = require('fs')
PATH = require('path')

module.exports =
  class TestJumperLeap

    constructor: ->

    getCurrentFilePath: ->
      atom.project.relativize(atom.workspace.activePaneItem.getUri())

    filenameIsSpec: (filename) ->
      spec_announcer = atom.config.get('test-jumper.spec-announcer')

      @constructor._matchFormat(spec_announcer,filename)

    leap: ->
      return unless atom.workspace.getActiveEditor()

      spec_announcer = atom.config.get('test-jumper.spec-announcer')
      currentFilePath = @getCurrentFilePath()
      filename = PATH.basename(currentFilePath)

      for target in @getMovementTargetForFilePath(currentFilePath)
        if @filenameIsSpec(filename)
          target_filename = @constructor._unformat(spec_announcer,filename)
        else
          target_filename = @constructor._format(spec_announcer,filename)

        t = target[1]
        openthis = t.replace(filename, target_filename)
        openthis = PATH.join(atom.project.getRootDirectory().path,openthis)

        if FS.existsSync openthis
          atom.workspace.open(openthis)



    getMovementTargetForFilePath: (filePath) ->
      replace_targets = @getMovementRulesForFilePath(filePath).filter (r) ->
        (new RegExp("^#{r[0]}")).test(filePath)

      replace_targets.map (target) ->
        [filePath, filePath.replace (new RegExp("^#{target[0]}")), target[1]]

    getMovementRulesForFilePath: (filePath) ->
      targets = atom.config.get('test-jumper.locations').map (location) ->
        location.split('|')

      filename = PATH.basename(filePath)

      if @filenameIsSpec(filename)
        return targets.map (t) ->
          [t[1],t[0]]
      else
        return targets


    # A very simple implementation of UTIL.format
    # Only supports one '%s'
    @_format: (format, replacement) ->
      replaced_string = format.replace(/^(.*)%s(.*)$/,"$1#{replacement}$2")
      replaced_string = replacement + format if format == replaced_string # legacy support
      return replaced_string

    # The inverse of @_format
    # Only supports one '%s'
    @_unformat: (format, formatted_string) ->
      format_parts = format.split(/%s/)
      format_parts.unshift '' if format_parts.length == 1 # legacy support
      formatted_string.replace(new RegExp("^#{format_parts[0]}(.*)#{format_parts[1]}$"),'$1')

    # returns true if the formatted_string was created using format
    # Only supports one '%s'
    @_matchFormat: (format, formatted_string) ->
      return @_unformat(format, formatted_string) != formatted_string
