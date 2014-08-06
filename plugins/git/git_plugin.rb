class GitPlugin < Plugin

  def plugin_tag
    "git"
  end

  def ensure_correct_branch(bo)
    cb = `#{git_cmd} rev-parse --abbrev-ref HEAD`
    cb = cb.strip
    if bo['branch'] != cb
      puts "switching branch"
      `#{git_cmd} fetch origin`
      `#{git_cmd} checkout -b #{bo['branch']} origin/#{bo['branch']}`
    end
  end

  def has_changes(project)
    bo = project.get_plugin_configuration('git')
    ensure_correct_branch(bo)

    local = nil
    remote = nil
    `#{git_cmd} fetch`
    local  = `#{git_cmd} rev-parse HEAD`
    remote = `#{git_cmd} rev-parse origin/#{bo['branch']}`
    local != remote
  end

  def update_from_remote(project)
    bo = project.get_plugin_configuration('git')
    `#{git_cmd} pull origin #{bo['branch']}`
  end

  def checkout_from_remote(project)
    bo = project.get_plugin_configuration('git')
    `#{git_cmd} clone #{bo['repo']} .`
    ensure_correct_branch(bo)
  end

  def git_cmd
    if @git == nil
      @git = `which git` 
      @git = @git.gsub("\n", '')
    end
    @git
  end

end

TraceMake.register_plugin(GitPlugin.new)
