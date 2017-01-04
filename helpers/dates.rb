# [Dates]
module Dates
  def current_week
    Date.today.strftime('%G%V')
  end
end
