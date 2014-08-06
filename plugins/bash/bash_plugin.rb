class BashPlugin < Plugin

  def plugin_tag
    "bash"
  end

  def test?
    true
  end

  def test(project)
    bo = project.get_plugin_configuration("bash")
    results = `#{bo['test_command']}`
    success = $?.to_i == 0
    { success:success, output:results, code_coverage:0 }
  end

  def build?
    true
  end

  def build(project)
    bo = project.get_plugin_configuration("bash")
    cmd = bo['build_command'].gsub("BUILD_NUMBER", "#{project.build_number}")
    results = `#{cmd}`
    success = $?.to_i == 0
    { :success => success, :output => results, :results =>[bo['build_result']]}
  end

  def get_code_coverage(project, success)
  end

end

TraceMake.register_plugin(BashPlugin.new)

