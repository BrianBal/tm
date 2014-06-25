class HipchatPlugin < Plugin

  def plugin_tag
    "hipchat"
  end

  def after_test(project)
    opts = get_options(project)
    room = opts['room']
    client = HipChat::Client.new(opts['token'])
    if project.test_result[:success]
      client[room].send('TraceMake', success_message_for_test(project))
    else
      client[room].send('TraceMake', fail_message_for_test(project))
    end
  end

  def after_build(project)
    opts = get_options(project)
    room = opts['room']
    client = HipChat::Client.new(opts['token'])
    if project.build_result[:success]
      client[room].send('TraceMake', success_message_for_build(project))
    else
      client[room].send('TraceMake', fail_message_for_build(project))
    end
  end

  def get_options(project)
    project.get_plugin_configuration("hipchat")
  end

  def success_message_for_test(project)
    cc = project.test_result[:code_coverage]
    ":) Tests passed for build ##{project.build_number} #{project.name}  #{cc}% code coverage"
  end

  def fail_message_for_test(project)
    ":( Tests FAILED for build ##{project.build_number} #{project.name}"
  end

  def success_message_for_build(project)
    ":) Build ##{project.build_number} ready for #{project.name}"
  end

  def fail_message_for_build(project)
    ">:( Build ##{project.build_number} FAILED for #{project.name}"
  end

end

TraceMake.register_plugin(HipchatPlugin.new)
