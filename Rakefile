# Rakefile

# Asset pipeline
require 'sinatra/asset_pipeline/task'
require './app'

# rspec
require 'rspec/core/rake_task'

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
  runweek = Date.today.strftime('%G%V')
  startdate = Date.commercial(runweek[0, 4].to_i, runweek[4, 2].to_i)
  # get the current conditions
  current_week = Week.find_by(week_num: runweek) ||
                 Week.create(
                   week_num: runweek,
                   start_date: startdate
                 )
  day = Date.today.strftime('%A').downcase

  # Loop through all of the users
  Cache.redis.pipelined do
    User.all.each { |u| u.email_reminder(current_week.id, day) }
  end
end
