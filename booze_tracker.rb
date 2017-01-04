# Core stuffs
require 'rubygems'
require 'bundler'
ENV['RACK_ENV'] ||= 'development'
Bundler.require(:core, :assets, ENV['RACK_ENV'])
require 'dotenv'
Dotenv.load

# some sinatra things
require 'sinatra/asset_pipeline'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

# workaround for rake / sinatra namespace clash
self.instance_eval do
  alias :namespace_pre_sinatra :namespace if self.respond_to?(:namespace, true)
end

require 'sinatra/namespace'

self.instance_eval do
  alias :namespace :namespace_pre_sinatra if self.respond_to?(:namespace_pre_sinatra, true)
end

require './lib/cache'
require './lib/score'

# [BoozeTracker]
class BoozeTracker < Sinatra::Base
  include Cache

  configure do
    set :assets_precompile,
        %w(app.js app.css *.png *.jpg *.svg *.eot *.ttf *.woff)
    set :assets_css_compressor, :sass
    set :assets_js_compressor, :uglifier
    register Sinatra::AssetPipeline
    register Sinatra::Flash
    register Sinatra::Namespace
    helpers Sinatra::RedirectWithFlash

    # Actual Rails Assets integration, everything else is Sprockets
    if defined?(RailsAssets)
      RailsAssets.load_paths.each do |path|
        settings.sprockets.append_path(path)
      end
    end
  end
end

require './config/environments'
require './extensions/google_oauth2'
require './routes/init'
require './helpers/init'
require './models/init'
