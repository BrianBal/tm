class TestFlightPlugin < Plugin

  def plugin_tag
    "testflight"
  end

  def after_test(project)
  end

  def after_build(project)
    if project.build_result[:success]
      api_file = project.build_result[:results][0]
      opts = project.get_plugin_configuration("testflight")
      res = `curl http://testflightapp.com/api/builds.json -F file=@"#{api_file}" -F api_token='#{opts['api_token']}' -F team_token='#{opts['team_token']}' -F notes='Automated Build from TraceMake' -F notify=#{opts['notify'] ? "True" : "False"} -F distribution_lists='#{opts['distribution_lists']}'`
      puts res
      if project.build_result[:output]
        project.build_result[:output] += "\n" + res
      else
        project.build_result[:output] = res
      end
    end
  end

end
