# Rakefile

# Asset pipeline
require 'sinatra/asset_pipeline/task'
require './app'

Sinatra::AssetPipeline::Task.define!(App)

# Active record stuff
require 'sinatra/activerecord/rake'

# Rake console is fun!
task :console do
  require 'irb'
  require 'irb/completion'
  require './app' # You know what to do.
  ARGV.clear
  IRB.start
end

task :test do
  puts "Test in progress"
end

task :emailer do
  require 'securerandom'
  baseurl = 'http://boozetracker.marsupialmusic.net/token/'
  runweek = Date.today.strftime("%G%V")
  # get the current conditions
  current_week = Week.find_by(week_num: runweek) ||
    Week.create(
      week_num: runweek,
      start_date: Date.commercial(runweek[0,4].to_i,runweek[4,2].to_i)
    )

  day = Date.today.strftime('%A').downcase

  # Loop through all of the users
  $redis.pipelined do
    # TODO: this can go to the model
    User.all.each do |u|
      puts "checking #{u.name}"
      my_result = u.weekly_results.find_by(week_id: current_week.id) ||
        u.weekly_results.create(week_id: current_week.id)
      # if they haven't entered any results, send an email
      if my_result.send("#{day}_drinks").nil?
        # generate a token and save to Redis
        puts "No data for #{u.name} - #{Date.today}. Sending email"
        my_token = SecureRandom.urlsafe_base64
        packet = {
          user: u.id,
          result: my_result.id,
          parameter: day
        }
        $redis.set(my_token,packet.to_json,{ex: 604800})

        # send email
        message = Mail.new do
          from    ENV['EMAIL_FROM']
          to      "#{u.name} <#{u.email}>"
          subject 'BoozeTracker Reminder'
          content_type 'text/html; charset=UTF-8'
          body    "<p>Did you have a drink yesterday?</p><p><a href='#{baseurl}#{my_token}?result=yes'>Yes</a> | <a href='#{baseurl}#{my_token}?result=no'>No</a></p>"
          delivery_method Mail::Postmark, api_token: ENV['POSTMARK_API_TOKEN']
        end
        message.deliver
      else
        # no worries
        puts "Data found"
      end
    end
  end
end
