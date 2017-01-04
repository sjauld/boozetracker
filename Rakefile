# Rakefile

# Asset pipeline
require 'sinatra/asset_pipeline/task'
require './booze_tracker'

# rspec
require 'rspec/core/rake_task' if ENV['RACK_ENV'] == 'test'

Sinatra::AssetPipeline::Task.define!(BoozeTracker)

# Active record stuff
require 'sinatra/activerecord/rake'

# Rake console is fun!
task :console do
  require 'irb'
  require 'irb/completion'
  require './booze_tracker' # You know what to do.
  ARGV.clear
  IRB.start
end

task :prune_db do
  puts 'Pruning weekly results'
  # Where to put this stuff?
  WeeklyResult.where("
    monday_drinks IS NULL AND
    tuesday_drinks IS NULL AND
    wednesday_drinks IS NULL AND
    thursday_drinks IS NULL AND
    friday_drinks IS NULL AND
    saturday_drinks IS NULL AND
    sunday_drinks IS NULL").each do |row|
    puts "Pruning row #{row.id}"
    row.delete
  end
end

task :emailer do
  # runweek = Date.today.strftime('%G%V')
  # startdate = Date.commercial(runweek[0, 4].to_i, runweek[4, 2].to_i)
  # get the current conditions
  # current_week = Week.find_by(week_num: runweek) ||
  #                Week.create(
  #                  week_num: runweek,
  #                  start_date: startdate
  #                )
  # day = Date.today.strftime('%A').downcase
  day = Date.today

  # Loop through all of the users
  Cache.redis.pipelined do
    User.all.each do |u|
      # old reminder
      # u.email_reminder(current_week.id, day)
      # new reminder
      u.email_reminder(day)
    end
  end
end

task :migrate_v1_to_v2 do
  puts 'Converting WeeklyResults to new storage format'
  WeeklyResult.all.each do |wr|
    puts "Row #{wr.id}"
    date = wr.week.start_date - 1
    user = wr.user
    (1..7).each do |day|
      result = case wr.send "#{Date::DAYNAMES[day % 7].downcase}_drinks"
               when 1
                 false
               when 2
                 true
               end
      begin
        puts "Saving #{date + day}"
        user.save_result!(date + day, result)
      rescue ArgumentError => e
        puts e.message
      end
    end
  end
end
