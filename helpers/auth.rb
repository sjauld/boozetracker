module Auth
  def build_user
    if @user.nil? && !session['email'].nil?
      if User.where(email: session['email']).count == 0
        User.create(
          name: session['name'],
          email: session['email'],
          first_name: session['first_name'],
          last_name: session['last_name'],
          image: session['image']
        )
        flash[:notice] = "New user successfully created for #{session[:email]}"
      end
      @user = User.where(email: session['email']).first
      puts "User: #{@user.inspect}"
    end
    @user
  end

  def authorize
    if @user.nil? || @user['email'].nil?
      redirect to('/401')
    end
  end

  def authorized?
    !(@user.nil? || @user['email'].nil?)
  end

end
