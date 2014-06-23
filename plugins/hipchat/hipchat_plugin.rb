class HipchatPlugin < Plugin

  def plugin_tag
    "hipchat"
  end

  def after_test(project)
    # TODO: get token from config
    # TODO: get message from config
    #client = HipChat::Client.new("0a81342c9ed63232ddf8099b6065e1")
    if project.test_result[:success]
      #client['code_commits'].send('TraceMake', success_message_for_test(project))
      puts success_message_for_test(project)
    else
      #client['code_commits'].send('TraceMake', fail_message_for_test(project))
      puts fail_message_for_test(project)
    end
  end

  def after_build(project)
    # TODO: get token from config
    # TODO: get message from config
    #client = HipChat::Client.new("0a81342c9ed63232ddf8099b6065e1")
    if project.build_result[:success]
      #client['code_commits'].send('TraceMake', success_message_for_build(project))
      puts success_message_for_build(project)
    else
      #client['code_commits'].send('TraceMake', fail_message_for_build(project))
      puts fail_message_for_build(project)
    end
  end

  def success_message_for_test(project)
    ":) Tests passed for #{project.name}"
  end

  def fail_message_for_test(project)
    ":( Tests failed for #{project.name}"
  end

  def success_message_for_build(project)
    ":) Tests passed for #{project.name}"
  end

  def fail_message_for_build(project)
    ":) Tests passed for #{project.name}"
  end

end

TraceMake.register_plugin(HipchatPlugin.new)
