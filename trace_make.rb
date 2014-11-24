require 'rubygems'
require 'bundler'
require 'sinatra'
require './tm'

Bundler.setup

configure do

  set :bind, '192.168.1.48'
  set :port, '3000'

end

get '/' do
  projects = []
  project_files = Dir.glob(PROJECTS_DIR + '/*.json')
  project_files.each do |project_file|
    contents = File.open(project_file, 'rb') { |f| f.read }
    project = Project.new
    project.workspace = WORKSPACE_DIR
    project.setup(JSON.parse(contents, :symbolize_names => true))
    projects << project
  end

  haml :home, :layout => :layout, :locals => { :projects => projects }
end
