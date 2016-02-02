class App < Sinatra::Base

  # unsubscribe a user (admin use only - protect this or remove)
  get '/user/:id/unsubscribe' do
    this_user = User.find(params[:id])
    this_user.unsubscribed = true
    this_user.save
    flash[:notice] = "#{this_user.name} has been unsubscribed"
    redirect '/'
  end

  # self management of email subscription
  get '/user/toggle-subscription' do
    if !params[:token].nil?
      packet = JSON.parse($redis.get(params[:token])) rescue nil
      if packet.nil?
        flash[:error] = 'It looks like this token has expired.'
        redirect to('/')
      else
        unless authorized?
          session['email'] = User.find(packet['user']).email
          build_user
        end
      end
    end
    @user.unsubscribe
    flash[:notice] = "Subscription set to #{!@user.unsubscribed}"
    redirect "/user?user=#{@user.id}"
  end

  # user profile
  get '/user' do
    @this_user = User.find(params[:user]) rescue @user
    haml :profile
  end

  # legacy - to be removed
  get '/unsubscribe' do
    user = User.find(params[:user]) rescue @user
    if user.nil?
      flash[:error] = 'User ID incorrect or not provided'
      redirect '/'
    end
    user.unsubscribe
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
