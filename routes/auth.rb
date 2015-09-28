class App < Sinatra::Base

  before '/*' do
    build_user
  end

  before '/user/*' do
    authorize
  end

  # Unauthorized
  get '/401' do
    status 401
    haml :_401
  end

  not_found do
    status 404
    haml :_404
  end

  # login section
  get '/login' do
    @title = "log in"
    if session['email'].nil?
      redirect to('/auth/google_oauth2')
    else
      redirect to('/')
    end
  end

  get '/auth/google_oauth2/callback' do
    @title = "logged in"
    session.clear
    puts auth_hash.inspect
    auth_hash.info.each_pair do |k,v|
      session[k] = v
    end
    session['id'] = auth_hash['uid']
    puts session.inspect
    # do whatever you want with the information!
    redirect to('/')
  end

  get '/logout' do
    @title = "log out"
    session.clear
    redirect to('/')
  end

  def auth_hash
    request.env['omniauth.auth']
  end

end
