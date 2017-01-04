# [Score]
class Score
  class << self
    DRY_DAY_POINTS = 5.freeze
    BEER_DAY_PENALTY = -1.freeze
    MAXIMUM_WEEK = 10.freeze

    # Calculate the score for a month from the data array
    #
    # @param [Array<Hash>] data
    # @return [Integer] the score for a month
    def calculate_for_month_from_hash(data)
      data.each_slice(7).reduce(0) do |sum, d|
        sum + calculate_for_week_from_hash(d)
      end
    end

    # Converts the array of day hashes to a score
    #
    # @param [Array<Hash>] data
    # @return [Integer] the score for a week
    def calculate_for_week_from_hash(data)
      calculate_for_week(data.map { |d| d[:result] }.compact.join)
    end

    # Converts a data string to a score
    #
    # @param [String] data 2=beer day, 1=dry day, 0=no input, nil=outside range
    # @return [Type] description of returned object
    def calculate_for_week(data)
      beer_days = data.count('2')
      dry_days = data.count('1')
      [
        beer_days * BEER_DAY_PENALTY + dry_days * DRY_DAY_POINTS, MAXIMUM_WEEK
      ].min
    end
  end
end
