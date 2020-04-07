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
      spec_identifier = atom.config.get('test-jumper.test_identifier', scope: @config_descriptor)
      PATH.basename(filename).match(spec_identifier)

    leap: ->
      console.log("jumping")
      @editor = atom.workspace.getActiveTextEditor()
      @config_descriptor = @editor.getRootScopeDescriptor()
      return unless atom.workspace.getActivePaneItem()
      test_template = atom.config.get(@config_descriptor, 'test-jumper.test_template')

      currentFilePath = @getCurrentFilePath()
      filename = PATH.basename(currentFilePath)
      for target in @getMovementTargetForFilePath(currentFilePath)
        is_spec = @filenameIsSpec(filename)
        if is_spec
          target_filename = @spec_to_src(filename)
        else
          target_filename = @src_to_spec(filename)

        t = target[1]
        new_directory = PATH.dirname(t)
        new_filename = PATH.basename(currentFilePath).replace(filename, target_filename)
        openthis = PATH.join(@getCurrentProjectPath(), new_directory, new_filename)

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
      targets = atom.config.get('test-jumper.path_pairs', scope: @config_descriptor)
      return [] unless targets
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

    spec_to_src:(filename) ->
       r = new RegExp(atom.config.get('test-jumper.test_matcher', scope: @config_descriptor))
       t = atom.config.get('test-jumper.source_template', scope: @config_descriptor)
       @template_replace(r,t,filename)

    src_to_spec:(filename) ->
       r = new RegExp(atom.config.get('test-jumper.source_matcher', scope: @config_descriptor))
       t = atom.config.get('test-jumper.test_template', scope: @config_descriptor)
       @template_replace(r,t,filename)

    template_replace: (regex, target, filename) ->
      for match in regex.exec(filename)[1..-1]
        target = target.replace("{}", match);
      return target
