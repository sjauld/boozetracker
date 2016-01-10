class App < Sinatra::Base

  get '/user' do
    @this_user = User.find(params[:user]) rescue @user
    haml :profile
  end
  

end
