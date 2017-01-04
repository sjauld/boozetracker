require_relative 'auth'
require_relative 'booze'
require_relative 'v1/results'
require_relative 'v1/token'
require_relative 'users'

# [BoozeTracker]
class BoozeTracker < Sinatra::Base
  get '/' do
    @rundate = params[:date] ? Date.parse(params[:date]) : Date.today
    @users = User.where('updated_at > ?', @rundate.to_time.beginning_of_month)
                 .sort do |x, y|
      [y(&:monthly_score(@rundate)), x(&:monthly_dry_days(@)] <=>
      [x(&:monthly_score(@rundate)), y(&:monthly_dry_days(@)]
    end
    haml :index
  end
end
