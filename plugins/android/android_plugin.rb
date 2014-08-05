class AndroidPlugin < Plugin

  def plugin_tag
    "android"
  end

  def test(project)
    results = ""
    success = false
    code_coverage = 0
    bo = android_options(project)
    Dir.chdir(bo['root_dir']) do
      results = `#{bo['gradle']} #{bo['project']}:connectedAndroidTest`
      puts "#{bo['gradle']} #{bo['project']}:connectedAndroidTest"
      puts results
      success = $?.to_i == 0
      code_coverage = 0
    end
    { success:success, output:results, code_coverage:code_coverage }
  end

  def test?
    true
  end

  def build(project)
    nil
  end

  def build?
    false
  end

  def android_options(project)
    opts = {}
    opts['gradle'] = "./gradlew"
    opts['project'] = project.name
    opts['root_dir'] = "./"
    opts = opts.merge(project.get_plugin_configuration("android"))
    p opts
    opts
  end

end

TraceMake.register_plugin(AndroidPlugin.new)
