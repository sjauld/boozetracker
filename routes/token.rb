class App < Sinatra::Base

  get '/token/:token' do
    packet = JSON.parse($redis.get(params[:token])) rescue nil
    if packet.nil?
      'It looks like this token has expired. Maybe try updating your results via the <a href="/">website</a>.'
    else
      my_result = WeeklyResult.find(packet['result'])
      my_result.send "#{packet['parameter']}=", params[:result] == 'yes' ? true : params[:result] == 'no' ? false : nil
      my_result.save
      if params[:result] == 'yes'
        'Mmmm... beer.'
      elsif params[:result] == 'no'
        "Nice one. You have had #{my_result.dry_days.to_i} dry day(s) this week."
      else
        'I think you stuffed something up there'
      end
    end
  end

end
