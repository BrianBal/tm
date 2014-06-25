class Project

  attr_accessor :name, :build_number, :config, :test_result, :build_result

  def add_plugins(plugins)
    @plugins = plugins
  end

  def update_attributes(attrs)
    @name = attrs['name'] ? attrs['name'] : "My Project"
    @config = attrs
    @test_without_change = true
    @build_without_change = false
  end

  def get_plugin_configuration(plugin_name)
    @config[plugin_name]
  end

  def workspace_name
    @name.downcase.gsub(" ", "_")
  end

  def workspace_path
    "#{WORKSPACE_DIR}/#{self.workspace_name}"
  end

  def data_file_path
    "#{DATA_DIR}/#{self.workspace_name}.json"
  end

  def test_log_file_path
    "#{DATA_DIR}/#{self.workspace_name}_#{@build_number}_test.log"
  end

  def data_file_path
    "#{DATA_DIR}/#{self.workspace_name}_#{@build_number}_build.log"
  end

  def save_data_to_file
    b = {}
    b['build_number'] = @build_number
    b['test'] = @test_result[:success]
    b['build'] = @build_result[:success]
    @data['build_number'] = @build_number
    @data['name'] = @name
    @data['build_results'] << b
    File.open(data_file_path, 'w') {|f| f.write(@data.to_json) }

    bo = @build_result[:output]
    if bo
      File.open(build_log_file_path, 'w') {|f| f.write(bo) }
    end
    to = @test_result[:output]
    if to
      File.open(data_file_path, 'w') {|f| f.write(to) }
    end
  end

  def load_data_from_file
    if File.exist? data_file_path
      contents = File.open(data_file_path, 'rb') { |f| f.read }
      @data = JSON.parse(contents)
    end

    if @data == nil
      @data = {}
      @data['build_number'] = 0
      @data['build_results'] = []
    end

    @build_number = @data['build_number'] + 1
  end

  def test_and_build
    setup
    has_changes = remote_has_changes
    if has_changes
      puts " + remote has changes"
      udpate_from_remote
    end

    should_test = @test_without_change
    if has_changes
      should_test = true
    end
    if should_test
      if test
        puts "   + tests passed"
        if build
          puts "   + build complete"
        else
          puts "   + BUILD FAILED"
        end
      else
        puts "   + TESTS FAILED"
      end
      save_data_to_file
    end
  end

  def test
    puts " + testing #{@name}"
    success = false
    Dir.chdir(workspace_path) do
      before_test
      @plugins.each do |plugin|
        if plugin.test?
          @test_result = plugin.test(self)
        end
      end
      after_test
    end
    if @test_result
      success = @test_result[:success]
    end
    success
  end

  def before_test
    @plugins.each do |plugin|
      plugin.before_test(self)
    end
  end

  def after_test
    @plugins.each do |plugin|
      plugin.after_test(self)
    end
  end

  def build
    puts " + building #{@name}"
    success = false
    Dir.chdir(workspace_path) do
      before_build
      @plugins.each do |plugin|
        if plugin.build?
          @build_result = plugin.build(self)
        end
      end
      after_build
    end
    if @build_result
      success = @build_result[:success]
    end
    success
  end

  def before_build
    @plugins.each do |plugin|
      plugin.before_build(self)
    end
  end

  def after_build
    @plugins.each do |plugin|
      plugin.after_build(self)
    end
  end

  def setup
    puts " + setting up #{@name}"
    load_data_from_file
    setup_workspace_dir
    setup_repo
  end

  def setup_workspace_dir
    if ! Dir.exist? workspace_path
      puts "   + creating workspace"
      Dir.mkdir(workspace_path)
    end
  end

  def setup_repo
    if ! File.exist?("#{workspace_path}/.git")
      puts "   + cloning repo"
      Dir.chdir(workspace_path) do
        @plugins.each do |plugin|
          pres = plugin.checkout_from_remote(self)
          if pres != nil
            break
          end
        end
      end
    end
  end

  def remote_has_changes
    changed = false
    puts " + checking remote for changes"
    Dir.chdir(workspace_path) do
      @plugins.each do |plugin|
        pres = plugin.has_changes(self)
        if pres != nil
          changed = pres
          break
        end
      end
    end
    changed
  end

  def udpate_from_remote
    puts " + updating from remote"
    Dir.chdir(workspace_path) do
      @plugins.each do |plugin|
        pres = plugin.update_from_remote(self)
        if pres != nil
          break
        end
      end
    end
  end

end
