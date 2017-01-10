# [Score]
class Score
  class << self
    DRY_DAY_POINTS = 5
    BEER_DAY_PENALTY = -1
    MAXIMUM_WEEK = 10

    # Calculate the score for a month from the data array
    #
    # @param [Array<Hash>] data
    # @return [Hash] a hash of official score and display score
    def calculate_for_month_from_hash(data)
      data.each_slice(7).reduce(official: 0, display: 0) do |sum, d|
        res = calculate_for_week_from_hash(d)
        { official: sum[:official] + res[:official],
          display: sum[:display] + res[:display] }
      end
    end

    # Converts the array of day hashes to a score
    #
    # @param [Array<Hash>] data
    # @return [Hash] a hash of official score and display score
    def calculate_for_week_from_hash(data)
      calculate_for_week(data.map { |d| d[:result] }.compact.join)
    end

    # Converts a data string to a score
    #
    # @param [String] data 2=beer day, 1=dry day, 0=no input, nil=outside range
    # @return [Hash] a hash of official score and display score
    def calculate_for_week(data)
      beer_days = data.count('2')
      dry_days = data.count('1')
      nondry_days = beer_days + data.count('0')
      display_score = [
        beer_days * BEER_DAY_PENALTY + dry_days * DRY_DAY_POINTS, MAXIMUM_WEEK
      ].min
      official_score = [
        nondry_days * BEER_DAY_PENALTY + dry_days * DRY_DAY_POINTS, MAXIMUM_WEEK
      ].min
      { display: display_score, official: official_score }
    end
  end
end
