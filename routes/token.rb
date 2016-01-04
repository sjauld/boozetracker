class App < Sinatra::Base

  get '/token/:token' do
    "Token: #{params[:token]}, result: #{params[:result]}"
  end

end
