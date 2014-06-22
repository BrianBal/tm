class GitPlugin < Plugin

  def plugin_tag
    "git"
  end

  def has_changes(project)
    #TOOD: merge options
    bo = project.get_plugin_configuration('git')

    local = nil
    remote = nil
    `#{GIT} fetch`
    local  = `#{GIT} rev-parse HEAD`
    remote = `#{GIT} rev-parse origin/#{bo['branch']}`
    local != remote
  end

  def update_from_remote(project)
    #TOOD: merge options
    bo = project.get_plugin_configuration('git')
    `#{GIT} pull origin #{bo['branch']}`
  end

  def checkout_from_remote(project)
    #TOOD: merge options
    bo = project.get_plugin_configuration('git')
    `#{GIT} clone #{bo['repo']} .`
  end

end

TraceMake.register_plugin(GitPlugin.new)
