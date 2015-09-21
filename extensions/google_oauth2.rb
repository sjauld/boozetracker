class App < Sinatra::Base
  use Rack::Session::Cookie, secret: Digest::SHA2.hexdigest("#{ENV['GOOGLE_ID']}+#{ENV['GOOGLE_SECRET']}")
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if ENV['RACK_ENV'] == 'development'
  use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_ID'], ENV['GOOGLE_SECRET'], {}
  end
end
