#_ = require 'underscore'
FS = require('fs')
PATH = require('path')

module.exports =
  class TestJumperLeap

    constructor: ->

    getCurrentFileFullPath: ->
      atom.workspace.getActivePaneItem().getURI()

    getCurrentFilePath: ->
      atom.project.relativize(@getCurrentFileFullPath())

    getCurrentProjectPath: ->
      file = @getCurrentFilePath()
      filePath = @getCurrentFileFullPath()
      currentProjectPath = atom.project.getDirectories()[0].path

      for project in atom.project.getDirectories()
        projectFilePath = PATH.join(project.path, file)
        if (projectFilePath == filePath)
          currentProjectPath = project.path

      return currentProjectPath

    filenameIsSpec: (filename) ->
      spec_announcer = atom.config.get('test-jumper.spec-announcer')

      filename = @constructor._extensionFreeBasename(filename)

      @constructor._matchFormat(spec_announcer,filename)

    leap: ->
      return unless atom.workspace.getActiveTextEditor()

      spec_announcer = atom.config.get('test-jumper.spec-announcer')
      currentFilePath = @getCurrentFilePath()
      filename = @constructor._extensionFreeBasename(currentFilePath)

      for target in @getMovementTargetForFilePath(currentFilePath)
        is_spec = @filenameIsSpec(filename)
        if is_spec
          target_filename = @constructor._unformat(spec_announcer,filename)
        else
          target_filename = @constructor._format(spec_announcer,filename)

        t = target[1]
        openthis = t.replace(filename, target_filename)
        openthis = PATH.join(@getCurrentProjectPath(),openthis)

        if FS.existsSync openthis
          split_side = if is_spec
            'left'
          else
            'right'

          open_options =
            searchAllPanes: true
          open_options['split'] = split_side if atom.config.get('test-jumper.spec_to_the_right')
          atom.workspace.open(openthis, open_options)

        else if atom.config.get('test-jumper.x-create-files.enabled')
          src_filename = if is_spec
            PATH.basename(openthis)
          else
            PATH.basename(target[0])

          @createFile(openthis,src_filename,! is_spec)
          atom.workspace.open(openthis)



    getMovementTargetForFilePath: (filePath) ->
      replace_targets = @getMovementRulesForFilePath(filePath).filter (r) ->
        (new RegExp("^#{r[0]}")).test(filePath)

      replace_targets.map (target) ->
        [filePath, filePath.replace (new RegExp("^#{target[0]}")), target[1]]

    getMovementRulesForFilePath: (filePath) ->
      targets = atom.config.get('test-jumper.locations').map (location) ->
        location.split('|')

      if @filenameIsSpec(filePath)
        return targets.map (t) ->
          [t[1],t[0]]
      else
        return targets

    createFile: (openthis, src_filename, target_is_spec) ->
      @mkParentDirs openthis

      content = if target_is_spec
        atom.config.get('test-jumper.x-create-files.spec-template')
      else
        atom.config.get('test-jumper.x-create-files.source-template')
      content = content.split('%s').join(src_filename)
      content = content.split('\\n').join('\n')

      FS.writeFileSync(openthis,content)

    # Recursively creates all required parent directories
    mkParentDirs: (path) ->
      parent = PATH.dirname(path)
      return if FS.existsSync parent
      @mkParentDirs parent
      FS.mkdirSync parent

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

    @_extensionFreeBasename: (file_path) ->
      file_name = PATH.basename(file_path)
      return file_name.replace(/^([^\.]+).*$/,'$1')
