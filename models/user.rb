class User < ActiveRecord::Base
  has_many :weekly_results
end
