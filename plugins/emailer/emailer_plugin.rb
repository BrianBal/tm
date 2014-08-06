class EmailerPlugin < Plugin

  def plugin_tag
    "emailer"
  end

  def after_build(project)
    opts = get_options(project)
    subject = ""
    body = ""
    if project.build_result[:success]
      subject = "Build ##{project.build_number} of #{project.name}"
    else
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

  "to": ["brian@alpinereplay.com"],
    "smtp_server": "smpt.gmail.com",
    "port": "587",
    "user_name": "brian@alpinereplay.com",
    "password": "wrgTxG8KsRmA"
end
