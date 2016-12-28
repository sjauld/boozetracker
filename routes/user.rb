# [App]
class App < Sinatra::Base
  # user routes are protected
  before '/users/*' do
    authorize
  end

  #############
  # Hobo routes

  # self management of email subscription
  get '/users/toggle-subscription' do
    @user.toggle_subscription!
    flash[:notice] = "Subscription set to #{!@user.unsubscribed}"
    redirect "/users/#{@user.id}"
  end

  # unsubscribe
  get '/users/unsubscribe' do
    @user.unsubscribe!
    flash[:notice] = 'You have been unsubscribed'
    redirect "/users/#{@user.id}"
  end

  #############
  # Real routes

  # unsubscribe a user
  get '/users/:id/unsubscribe' do
    authorize_admin
    this_user = User.find(params[:id])
    this_user.unsubscribe!
    flash[:notice] = "#{this_user.name} has been unsubscribed"
    redirect '/'
  end

  # user profile
  get '/users/:id' do
    @this_user = User.find(params[:id])
    haml :profile
  end
end
