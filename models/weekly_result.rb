# [WeeklyResult]
class WeeklyResult < ActiveRecord::Base
  belongs_to :user
  belongs_to :week

  # Stores the result for a week
  #
  # @param [String] day the day of the week
  # @param [Type] result='asd' describe result='asd'
  # @return [Type] description of returned object
  def update(day, result = 'void')
    send("#{day}_drinks=", result_to_bool(result))
    dry_days = 0
    Date::DAYNAMES.map(&:downcase).each do |d|
      dry_days += (send "#{d}_drinks").zero? ? 1 : 0
    end
    self.dry_days = dry_days
    self.score = 10 + [dry_days - 3, 0].min * 5
    save
  end

  private

  # Converts a result string to a boolean or nil
  #
  # @param [String] result yes or no (or gibberish)
  # @return [Boolean] a boolean or nil
  def result_to_bool(result)
    case result
    when 'yes'
      true
    when 'no'
      false
    end
  end
end
