class App < Sinatra::Base

  get '/user/:id/unsubscribe' do
    this_user = User.find(params[:id])
    this_user.unsubscribed = true
    this_user.save
    flash[:notice] = "#{this_user.name} has been unsubscribed"
    redirect '/'
  end

  get '/user' do
    @this_user = User.find(params[:user]) rescue @user
    haml :profile
  end

  get '/unsubscribe' do
    user = User.find(params[:user]) rescue @user
    if user.nil?
      flash[:error] = 'User ID incorrect or not provided'
      redirect '/'
    end
    message = Mail.new do
      from    ENV['EMAIL_FROM']
      to      "sja@marsupialmusic.net"
      subject 'Boozetracker user unsubscribed'
      content_type 'text/html; charset=UTF-8'
      body    "#{user.name} has clicked unsubscribe"
      delivery_method Mail::Postmark, api_token: ENV['POSTMARK_API_TOKEN']
    end
    message.deliver
    flash[:notice] = "You may have been unsubscribed"
    redirect '/'
  end

end
