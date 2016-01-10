class App < Sinatra::Base

  get '/' do
    @year = params[:year] || Date.today.year
    @results = WeeklyResult.includes(:week).where("weeks.week_num > #{@year.to_i * 100} AND weeks.week_num < #{(@year.to_i + 1) * 100}").references(:week)
    @leaderboard = {}
    @results.each do |result|
      @leaderboard[result.user.email.to_sym] ||= {user: result.user, dry_days: 0, score: 0}
      @leaderboard[result.user.email.to_sym][:dry_days] += result.dry_days.to_i
      @leaderboard[result.user.email.to_sym][:score] += result.score.to_i
    end
    haml :index
  end

  get '/results/:weeknum' do
    # Validation
    begin
      raise 'Error - week results not yet created' unless week = Week.find_by_week_num(params[:weeknum])
      raise 'Error - not logged in' unless @user
      raise 'Error - user results for this week not yet created' unless user_results = (@user.weekly_results.find_by week_id: week.id)
    rescue => e
      flash[:error] = e.message
      redirect to ('/')
    end

    user_results.update(params[:day],params[:drink])
    flash[:notice] = "Your profile has been updated"
    redirect to("/week?date=#{week.week_num}")
  end

  get '/week' do
    # what week is it?
    @runweek = params[:date] || Date.today.strftime("%G%V")
    @rundate = Date.commercial(@runweek[0,4].to_i,@runweek[4,2].to_i)
    unless @week = Week.find_by_week_num(@runweek)
      @week = Week.create(week_num: @runweek,start_date: @rundate)
    end

    # run through the users and populate the weekly_results
    @all_users = User.all
    @all_users.each do |user|
      unless user.weekly_results.find_by week_id: @week.id
        user.weekly_results.create(week_id: @week.id)
      end
    end

    haml :week_results
  end

end
