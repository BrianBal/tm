class GitPlugin < Plugin

  def plugin_tag
    "git"
  end

  def scm?
    true
  end

  def is_setup
    ! File.exist?(".git")
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

  def scm_changes(project)
    bo = project.config_for_plugin('git')
    md = project.meta_data_for_plugin('git')

    # load branches
    mbranches = md[:branches]
    if mbranches == nil
      mbranches = []
    end
    branches = []
    changes = []

    heads = `#{git_cmd} ls-remote --heads #{bo[:repo]}`
    heads.lines.each do |line|
      parts = line.split("\t")
      if parts.count == 2
        branches << { :branch => parts[1].gsub("refs/heads/", "").strip, :commit => parts[0] }
      end
    end

    # find branches with changes
    branches.each do |b|
      changed = true
      mbranches.each do |mb|
        if mb[:branch] == b[:branch] && mb[:commit] == b[:commit]
          changed = false
        end
      end
      if changed && b[:branch].match(bo[:branch]) != nil
        changes << b
      end
    end

    # save branches for next time
    md[:branches] = branches
    project.set_meta_data_for_plugin('git', md)

    # return the changes
    changes
  end


  def scm_update_to_change(project, change)
    bo = project.config_for_plugin('git')

    # remove all files from directory
    files = Dir.glob("{*,.*}").delete_if { |f| f == "." || f == ".." }
    FileUtils.rm_rf files

    # clone the repo
    `#{git_cmd} clone --depth 1 --single-branch --branch #{change[:branch]} #{bo[:repo]} . >> /dev/null`
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
