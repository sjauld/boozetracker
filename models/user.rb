# [User]
class User < ActiveRecord::Base
  include Cache
  require 'securerandom'

  has_many :weekly_results

  BASE_URL = ENV['BASE_URL'] || 'http://boozetracker.marsupialmusic.net'

  # Toggle subscription status
  #
  # @return [void]
  def toggle_subscription!
    self.unsubscribed = !unsubscribed
    save
  end

  # Unsubscribe from daily reminders
  #
  # @return [void]
  def unsubscribe!
    self.unsubscribed = true
    save
  end

  # Retrive the drinking result for a day
  #
  # @param [Date] day the day you want a result for
  # @return [Boolean] true if you had a drink, false if not, if no answer
  def result(day)
    # @todo build
  end

  # Send an email reminder to the user
  def email_reminder(week_id, day)
    my_result = weekly_results.find_by(week_id: week_id) ||
                weekly_results.create(week_id: week_id)
    return unless my_result.send("#{day}_drinks").nil? && !unsubscribed
    send_email_reminder(create_token(day))
  end

  private

  # Sends an email reminder with hotlinks
  #
  # @param [String] token the hotlink token
  # @return [void]
  def send_email_reminder(token)
    message = Mail.new do
      from            ENV['EMAIL_FROM']
      to              "#{name} <#{email}>"
      subject         'BoozeTracker Reminder'
      content_type    'text/html; charset=UTF-8'
      body            email_body(token)
      delivery_method Mail::Postmark, api_token: ENV['POSTMARK_API_TOKEN']
    end
    message.deliver
  end

  # An email reminder
  # @todo put in views
  #
  # @param [String] token the hotlink token
  # @return [String] email body
  def email_body(token)
    '<p>Did you have a drink yesterday?</p><p><a href=' \
    "#{BASE_URL}/token/#{token}?result=yes'>Yes</a> | <a href=" \
    "'#{BASE_URL}/token/#{token}?result=no'>No</a></p><p>--</p>" \
    "<p>Brought to you by <a href='#{BASE_URL}'>BoozeTracker</a> | " \
    "<a href='#{BASE_URL}/users/toggle-subscription?token=" \
    "#{token}'>Unsubscribe</a></p>"
  end

  # generate a token and save to Redis
  #
  # @param [String] day the day of the week
  # @return [String] a token
  def create_token(day)
    my_token = SecureRandom.urlsafe_base64
    packet = { user: id, result: nil, parameter: day }
    redis.set(my_token, packet.to_json, ex: 1.week.to_i)
    my_token
  end
end
