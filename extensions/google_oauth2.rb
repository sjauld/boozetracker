# [BoozeTracker]
class BoozeTracker < Sinatra::Base
  secret = Digest::SHA2.hexdigest("#{ENV['GOOGLE_ID']}+#{ENV['GOOGLE_SECRET']}")
  use Rack::Session::Cookie, secret: secret
  if ENV['RACK_ENV'] == 'development'
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  end
  use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_ID'], ENV['GOOGLE_SECRET'], {}
  end
end
