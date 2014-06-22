require 'rubygems'
require 'bundler'
require 'fileutils'
require 'json'
require 'hipchat'

require './lib/project.rb'
require './lib/plugin.rb'

BASE_DIR = File.dirname(__FILE__)
WORKSPACE_DIR = "#{BASE_DIR}/workspace"
PROJECTS_DIR = "#{BASE_DIR}/projects"
PLUGINS_DIR = "#{BASE_DIR}/plugins"
GIT = "/usr/bin/git"

class TraceMake

  @@plugins = {}
  @@projects = []

  def self.register_plugin(plugin)
    @@plugins[plugin.plugin_tag] = plugin
  end

  def self.start
    project_files = Dir.glob(PROJECTS_DIR + '/*.json')
    project_files.each do |project_file|
      contents = File.open(project_file, 'rb') { |f| f.read }
      project = Project.new
      project.update_attributes(JSON.parse(contents))
      @@projects << project
    end

    plugin_dirs = Dir.glob(PLUGINS_DIR + "/*")
    plugin_dirs.each do |plugin_dir|
      rb_files = Dir.glob(plugin_dir + "/*.rb")
      rb_files.each do |rb_file|
        require rb_file
      end
    end

    @@projects.each do |project|
      plugins_for_project = []
      project.config.each do |pr_key, pr_value|
        @@plugins.each do |pl_key, pl_value|
          if pl_key == pr_key
            plugins_for_project << pl_value
          end
        end
      end
      puts "plugins_for_project: #{plugins_for_project}"
      project.add_plugins(plugins_for_project)
      project.test_and_build
    end
  end

end

TraceMake.start
