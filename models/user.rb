# [User]
class User < ActiveRecord::Base
  include Cache
  require 'securerandom'

  has_many :weekly_results

  BASE_URL = ENV['BASE_URL'] || 'http://boozetracker.marsupialmusic.net'

  ####################
  # Subscription stuff

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

  # Sends an email reminder if you haven't entered results and you're not
  # unsubscribed
  #
  # @param [Type] day describe day
  # @return [Type] description of returned object
  def email_reminder(day)
    return if result(day) || unsubscribed
    send_email_reminder(create_token(day))
  end

  # Retrive the drinking result for a day
  #
  # @param [Date] day the day you want a result for
  # @return [Boolean] true if you had a drink, false if not, if no answer
  def result(day)
    case result_string(day.year)[day.yday - 1]
    when '2'
      true
    when '1'
      false
    end
  end

  # Set the drinking result for a day
  #
  # @param [Date] day the day you want to set the result for
  # @param [Boolean] result true if you had a drink, false if not, nil to void
  # @return [void]
  def save_result!(day, result)
    old_results = result_string(day.year)
    old_results[day.yday - 1] = result_to_s(result)
    send("results_#{day.year}=", old_results)
    save
    'OK'
  end

  # The slice of the result string from a given month
  #
  # @param [Date] day
  # @return [String] the result string (2 = drink, 1 = no drink, 0 = void)
  def month_result_string(day)
    start = day.beginning_of_month.yday - 1
    finish = day.end_of_month.yday - 1
    result_string(day.year).slice(start..finish)
  end

  # The number of dry days in a month
  #
  # @param [Date] day
  # @return [Integer] the number of dry days in the month
  def monthly_dry_days(day)
    month_result_string(day).count('1')
  end

  # The score for a month
  #
  # @param [Date] day
  # @return [Integer] the score for a month
  def monthly_score(day)
    Score.calculate_for_month_from_hash(month_result_by_week(day))
  end

  # Gives you an array of results, padded to fit into weeks
  #
  # @param [Date] day
  # @return [Array<Hash>] description of returned object
  def month_result_by_week(day)
    output = []
    data = month_result_string(day)
    # front pad with null days
    (day.beginning_of_month.wday - 1).times do
      output << {result: nil, mday: nil}
    end
    # get the data
    data.each_char.with_index do |r, i|
      output << {result: r, mday: i + 1}
    end
    # end pad
    (- output.count % 7).times do
      output << {result: nil, mday: nil}
    end
    output
  end

  private

  # Sends an email reminder with hotlinks
  #
  # @param [String] token the hotlink token
  # @return [void]
  def send_email_reminder(token)
    recipient = "#{name} <#{email}>"
    body = email_body(token)
    message = Mail.new do
      from            ENV['EMAIL_FROM']
      to              recipient
      subject         'BoozeTracker Reminder'
      content_type    'text/html; charset=UTF-8'
      body            body
      delivery_method Mail::Postmark, api_token: ENV['POSTMARK_API_TOKEN']
    end
    message.deliver
  end

  # An email reminder
  # @todo put in views
  # @todo token auth???
  #
  # @param [String] token the hotlink token
  # @return [String] email body
  def email_body(token)
    '<p>Did you have a drink yesterday?</p><p><a href=' \
    "#{BASE_URL}/users/#{id}/result?date=#{token[:date]}&result=beer'>Yes</a>" \
    " | <a href='#{BASE_URL}/users/#{id}?date=#{token[:date]}&result=dry'>No" \
    "</a></p><p>--</p><p>Brought to you by <a href='#{BASE_URL}'>BoozeTracker" \
    "</a> | <a href='#{BASE_URL}/users/#{id}/unsubscribe'>Unsubscribe</a></p>"
  end

  # generate a token and save to Redis
  #
  # @param [Date] day the date
  # @return [String] a token
  def create_token(day)
    my_token = SecureRandom.urlsafe_base64
    packet = { user: id, date: day }
    redis.set(my_token, packet.to_json, ex: 1.week.to_i)
    my_token
  end

  # Pads the result string for a year
  #
  # @param [String] year
  # @return [String] the result string (2 = drink, 1 = no drink, 0 = void)
  def result_string(year)
    send("results_#{year}").rjust(366, '0')
  rescue NoMethodError
    raise ArgumentError, "#{year} out of range"
  end

  # The slice of the result string from a given week
  #
  # @param [Date] day
  # @return [String] the result string (2 = drink, 1 = no drink, 0 = void)
  def week_result_string(day)
    start_of_week = day.beginning_of_week
    # adjust if the week started in a different month
    start = (day.month == start_of_week.month ? start_of_week.day - 1 : 0)
    end_of_week = day.end_of_week
    # adjust if the week finished in a different month
    finish = (day.month == end_of_week.month ? end_of_week.day - 1 : 30)
    month_result_string(day).slice(start..finish)
  end

  # Some kind of array :)
  #
  # @param [Date] day
  # @return [Array] what is the point of this?
  def month_week_result_array(day)
    first_week_length = (7 - (day.wday + 6) % 7)
    data = month_result_string(day)
    [
      data[0..first_week_length - 1],
      data[first_week_length..7 + first_week_length - 1],
      data[first_week_length + 7..14 + first_week_length - 1],
      data[first_week_length + 14..21 + first_week_length - 1],
      data[first_week_length + 21..28 + first_week_length - 1],
      data[first_week_length + 28..35 + first_week_length - 1],
    ].compact
  end

  # Returns the integer for a result
  #
  # @param [Boolean] result true, false or nil
  # @return [Integer] 2, 1, 0
  def result_to_s(result)
    case result
    when true
      '2'
    when false
      '1'
    else
      '0'
    end
  end
end
