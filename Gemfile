ruby '2.4.0'

source 'https://rubygems.org' do
  group :core do
    # Basic things
    gem 'activerecord'
    gem 'haml'
    gem 'json', '~> 2.0'
    gem 'redis'
    gem 'sinatra'
    gem 'sinatra-activerecord', '~> 2.0.11'
    gem 'sinatra-asset-pipeline'
    gem 'sinatra-contrib', require: false
    gem 'sinatra-flash'
    gem 'sinatra-redirect-with-flash'
    gem 'uglifier'

    # Magic number function
    gem 'yahoo-finance'

    # auth
    gem 'omniauth-google-oauth2'

    # dev support
    gem 'dotenv'

    # email
    gem 'mail'
    gem 'postmark'
  end

  group :development, :test do
    gem 'rerun'
    gem 'rspec', require: false
    gem 'rubocop'
    gem 'simplecov'
    gem 'sqlite3'
    gem 'tux'
  end

  group :production do
    gem 'pg'
  end
end

source 'https://rails-assets.org' do
  group :assets do
    gem 'rails-assets-bootstrap'
    gem 'rails-assets-bootstrap3-datetimepicker'
    gem 'rails-assets-jquery'
    gem 'rails-assets-moment'
  end
end
