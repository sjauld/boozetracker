# [Auth]
module Auth
  include Cache

  def build_user
    return if @user || session['email'].nil?
    add_user if User.where(email: session['email']).empty?
    @user = User.where(email: session['email']).first
  end

  def default_user
    id = params[:dev_user] || 1
    @user = User.find(id)
  rescue
    puts 'Not logged in'
  end

  def add_user
    User.create(
      name: session['name'],
      email: session['email'],
      first_name: session['first_name'],
      last_name: session['last_name'],
      image: session['image']
    )
    flash[:notice] = "New user successfully created for #{session[:email]}"
  end

  def authorize
    default_user if ENV['RACK_ENV'] == 'development'
    login_with_token(params[:token]) if params[:token]
    redirect to('/401') unless authorized?
  end

  def authorized?
    !(@user.nil? || @user['email'].nil?)
  end

  def admin?
    @user.admin
  end

  def authorize_admin
    redirect to('/401') unless admin?
  end

  def authorize_edit(id)
    redirect to('/401') unless admin? || @user.id == id
  end

  private

  # Uses a token to authorize the user
  #
  # @param [String] token a randomly generated string
  # @return [void]
  def login_with_token(token)
    resp = redis.get(token)
    if resp
      packet = JSON.parse(resp)
      login_as(packet['user']) unless authorized?
    else
      flash[:error] = 'It looks like this token has expired.'
      redirect to('/')
    end
  end

  # Logs in as a specific user
  #
  # @param [Integer] id a user's uid
  # @return [void]
  def login_as(id)
    session['email'] = User.find(id).email
    build_user
  end
end
