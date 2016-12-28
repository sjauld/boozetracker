# [App]
class App < Sinatra::Base
  get '/token/:token' do
    resp = redis.get(params[:token])
    if resp.nil?
      flash[:error] = 'It looks like this token has expired.'
      redirect to('/')
    else
      packet = JSON.parse(resp)
      unless authorized?
        session['email'] = User.find(packet['user']).email
        build_user
      end

      # temporary fix to remove _drinks from old tokens
      day = packet['parameter'].split('_drinks').first

      my_result = WeeklyResult.find(packet['result'])
      my_result.update(day, params[:result])

      if params[:result] == 'yes'
        flash[:notice] = 'Mmmm... beer.'
      elsif params[:result] == 'no'
        flash[:notice] = 'Nice one. You have had ' \
                         "#{my_result.dry_days.to_i} dry day(s) this week."
      else
        flash[:error] = 'I think you stuffed something up there'
      end
    end
    redirect to("/week?date=#{my_result.week.week_num}")
  end
end
