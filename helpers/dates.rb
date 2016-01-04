module Dates
  #TODO: implement this helper and test
  def current_week
    Date.today.strftime("%G%V")
  end
end
