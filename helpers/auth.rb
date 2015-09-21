module Auth
  def build_user
    if @user.nil?
      @user = {}
      @user['email']  = session['email']
      @user['name']   = session['name']
      @user['id']     = session['id']
    # elsif ENV['RACK_ENV'] != 'production'
    #   @user['name']   = "Stuart Auld"
    #   @user['email']  = "sauld@cozero.com.au"
    #   @user['id']     = "sauld@cozero.com.au"
    end
    @user
  end

  def authorize
    build_user
    if @user.nil? || @user['email'].nil?
      redirect to('/401')
    end
  end

end
