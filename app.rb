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

class App < Sinatra::Base


  configure do
    set :assets_precompile, %w(app.js app.css *.png *.jpg *.svg *.eot *.ttf *.woff)
    set :assets_css_compressor, :sass
    set :assets_js_compressor, :uglifier
    register Sinatra::AssetPipeline

    # sinatra-flash
    enable :sessions
    register Sinatra::Flash
    helpers Sinatra::RedirectWithFlash

    # Actual Rails Assets integration, everything else is Sprockets
    if defined?(RailsAssets)
      RailsAssets.load_paths.each do |path|
        settings.sprockets.append_path(path)
      end
    end
  end

end

# require './config/environments'
require './extensions/google_oauth2'
require './routes/init'
require './helpers/init'
