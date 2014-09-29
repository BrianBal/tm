class Project

  attr_accessor :name, :meta, :config, :test_result, :build_result, :workspace

  def setup(jsonProject)
    # setup project properties
    @name = jsonProject[:project][:name]
    @config = jsonProject
    @plugins = []
    load_meta_data()

    # make sure directory structure is setup for project
    create_dir(project_source_path)
    create_dir(project_data_path)
    create_dir(project_builds_path)
  end

  def register_plugins(plugins)
    plugins.each do |p|
      @plugins << p
    end
  end

  def workspace_name
    @name.downcase.gsub(" ", "_")
  end

  def project_workspace_path
    "#{@workspace}/#{self.workspace_name}"
  end

  def project_source_path
    "#{@workspace}/#{self.workspace_name}/src"
  end

  def project_data_path
    "#{@workspace}/#{self.workspace_name}/data"
  end

  def project_meta_data_file_path
    "#{@workspace}/#{self.workspace_name}/data/meta.json"
  end

  def project_builds_path
    "#{@workspace}/#{self.workspace_name}/builds"
  end

  def project_build_path
    "#{@workspace}/#{self.workspace_name}/builds/#{build_number()}"
  end

  def test_log_file_path
    "#{project_build_path}/test.log"
  end

  def build_log_file_path
    "#{project_build_path}/build.log"
  end

  def create_dir(path)
    if ! File.directory?(path)
      FileUtils.mkdir_p(path)
      puts " + creating directory #{path}"
    end
  end

  def load_meta_data
    begin
      contents = File.open(project_meta_data_file_path, 'rb') { |f| f.read }
      @meta = JSON.parse(contents, :symbolize_names => true)
    rescue
      puts "failed to load meta data file"
      @meta = {}
    end
  end

  def save_meta_data
    File.open(project_meta_data_file_path, 'w') {|f| f.write(@meta.to_json) }
  end

  def config_for_plugin(plugin_name)
    @config[plugin_name.to_sym]
  end   

  def meta_data_for_plugin(plugin_name)
    m = @meta[plugin_name.to_sym]
    if m == nil
      m = {}
    end
    m
  end

  def set_meta_data_for_plugin(plugin_name, data)
    @meta[plugin_name.to_sym] = data
  end

  def build_number
    bm = @meta[:build_number]
    if bm == nil
      bm = 0
    end
    bm
  end

  def set_build_number(bm)
    @meta[:build_number] = bm
  end



  # SCM

  def find_changes
    changes = []

    Dir.chdir(project_source_path) do
      @plugins.each do |plugin|

        if plugin.scm?
          plugin.scm_changes(self).each do | change |
            changes << change
          end
        end

      end
    end

    changes
  end

  def update_to_change(change)
    Dir.chdir(project_source_path) do
      @plugins.each do |plugin|

        if plugin.scm?
          plugin.scm_update_to_change(self, change)
          break
        end

      end
    end
  end








  def test_and_build
    puts "\n + #{@name}"
    changes = find_changes()
    changes.each do |change|
      
      # update the build number
      set_build_number(build_number + 1)

      # create build directory to save results
      puts "build: #{project_build_path}"
      create_dir(project_build_path)

      # update source to change
      update_to_change(change)

      # test
      @plugins.each do |plugin|
        plugin.before_test(self)
      end
      test(change)
      @plugins.each do |plugin|
        plugin.after_test(self)
      end

      # build
      @plugins.each do |plugin|
        plugin.before_build(self)
      end
      build(change)
      @plugins.each do |plugin|
        plugin.after_build(self)
      end

    end

    save_meta_data
  end

  def test(change)
    
  end

  def build(change)
    puts "   - building #{change[:branch]}/#{change[:commit]}"
    success = false
    Dir.chdir(project_source_path) do
      @plugins.each do |plugin|
        if plugin.build?
          @build_result = plugin.build(self)
        end
      end
    end
    if @build_result
      success = @build_result[:success]

      # save log file
      puts "build_log_file_path: #{build_log_file_path}"
      File.open(build_log_file_path, 'w') {|f| f.write(@build_result[:output]) }

      # save build results
      @build_result[:results].each do |result|
        puts "result: #{result}"
        puts "to: #{project_build_path}#{File.basename(result)}"
        FileUtils.mv(result, "#{project_build_path}/#{File.basename(result)}")
      end
    end
    success
  end

end
