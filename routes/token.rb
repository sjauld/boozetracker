class App < Sinatra::Base

  get '/token/:token' do
    packet = JSON.parse($redis.get(params[:token])) rescue nil
    if packet.nil?
      flash[:error] = 'It looks like this token has expired.'
    else
      my_result = WeeklyResult.find(packet['result'])
      my_result.send "#{packet['parameter']}=", params[:result] == 'yes' ? true : params[:result] == 'no' ? false : nil
      my_result.save
      if params[:result] == 'yes'
        flash[:notice] = 'Mmmm... beer.'
      elsif params[:result] == 'no'
        flash[:notice] = "Nice one. You have had #{my_result.dry_days.to_i} dry day(s) this week."
      else
        flash[:error] = 'I think you stuffed something up there'
      end
    end
    redirect to('/')
  end

end
