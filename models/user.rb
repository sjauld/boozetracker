class User < ActiveRecord::Base
  has_many :weekly_results

  require 'securerandom'
  # TODO: move to config
  BASEURL = "http://boozetracker.marsupialmusic.net"

  # Toggle subscription status
  #
  # @return [void]
  def unsubscribe
    self.unsubscribed = !self.unsubscribed
    self.save
  end

  # Send an email reminder to the user
  def email_reminder(week_id,day)
    # can we use a template?
    puts "checking #{self.name}"
    my_result = self.weekly_results.find_by(week_id: week_id) ||
      self.weekly_results.create(week_id: week_id)
    if my_result.send("#{day}_drinks").nil? && !self.unsubscribed
      # generate a token and save to Redis
      puts "No data for #{self.name} - #{Date.today}. Sending email"
      my_token = SecureRandom.urlsafe_base64
      packet = {
        user: self.id,
        result: my_result.id,
        parameter: day
      }
      $redis.set(my_token,packet.to_json,{ex: 604800})
      # TODO: fix this bad workaround
      u = self
      # send email
      message = Mail.new do
        from    ENV['EMAIL_FROM']
        to      "#{u.name} <#{u.email}>"
        subject 'BoozeTracker Reminder'
        content_type 'text/html; charset=UTF-8'
        body    "<p>Did you have a drink yesterday?</p><p><a href='#{BASEURL}/token/#{my_token}?result=yes'>Yes</a> | <a href='#{BASEURL}/token/#{my_token}?result=no'>No</a></p><p>--</p><p>Brought to you by <a href='#{BASEURL}'>BoozeTracker</a> | <a href='#{BASEURL}/user/toggle-subscription?token=#{my_token}'>Unsubscribe</a></p>"
        delivery_method Mail::Postmark, api_token: ENV['POSTMARK_API_TOKEN']
      end
      message.deliver

    else
    end


  end
end
