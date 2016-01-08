class WeeklyResult < ActiveRecord::Base
  belongs_to :user
  belongs_to :week

  def update(day,result='asd')
    self.send "#{day}_drinks=", result == 'yes' ? true : result == 'no' ? false : nil
    dry_days = 0
    Date::DAYNAMES.map{|x| x.downcase}.each do |day|
      dry_days += (self.send "#{day}_drinks") == 0 ? 1 : 0
    end
    self.dry_days = dry_days
    self.score = 10 + ([dry_days - 3,0].min) * 5
    self.save
  end
end
