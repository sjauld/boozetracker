# Rakefile

# Asset pipeline
require 'sinatra/asset_pipeline/task'
require './app'

Sinatra::AssetPipeline::Task.define!(App)

# Active record stuff
require 'sinatra/activerecord/rake'

# Rake console is fun!
task :console do
  require 'irb'
  require 'irb/completion'
  require './app' # You know what to do.
  ARGV.clear
  IRB.start
end
