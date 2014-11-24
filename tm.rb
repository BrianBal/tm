require 'rubygems'
require 'bundler'
require 'fileutils'
require 'json'
require 'hipchat'
require 'clockwork'

require './lib/project.rb'
require './lib/plugin.rb'

BASE_DIR = File.dirname(__FILE__)
WORKSPACE_DIR = "#{BASE_DIR}/workspace"
PROJECTS_DIR = "#{BASE_DIR}/projects"
PLUGINS_DIR = "#{BASE_DIR}/plugins"
DATA_DIR = "#{BASE_DIR}/data"
GIT = "/usr/bin/git"

class TraceMake

  @@plugins = {}

  def self.register_plugin(plugin)
    @@plugins[plugin.plugin_tag.to_sym] = plugin
  end

  def self.init
    plugin_dirs = Dir.glob(PLUGINS_DIR + "/*")
    plugin_dirs.each do |plugin_dir|
      rb_files = Dir.glob(plugin_dir + "/*.rb")
      rb_files.each do |rb_file|
        require rb_file
      end
    end
  end

  def self.start
    puts "\nTraceMake starting to make stuff"
    projects = []
    project_files = Dir.glob(PROJECTS_DIR + '/*.json')
    project_files.each do |project_file|
      contents = File.open(project_file, 'rb') { |f| f.read }
      project = Project.new
      project.workspace = WORKSPACE_DIR
      project.setup(JSON.parse(contents, :symbolize_names => true))
      projects << project
    end

    projects.each do |project|
      plugins_for_project = []
      project.config.each do |pr_key, pr_value|
        @@plugins.each do |pl_key, pl_value|
          if pl_key == pr_key
            plugins_for_project << pl_value
          end
        end
      end
      project.register_plugins(plugins_for_project)
      project.test_and_build
    end
    puts "\n\n"
  end

end


#TraceMake.init

#run = true
#while run do
#  TraceMake.start
#  sleep(900)
#end

#TraceMake.start
