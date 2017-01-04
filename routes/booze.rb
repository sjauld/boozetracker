# [BoozeTracker]
class BoozeTracker < Sinatra::Base
  include Rack::Utils

  get '/rules' do
    haml :rules
  end

  get '/booze' do
    @rundate = parse_date(params)
    opts = {
      rundate: @rundate,
      divisor: params[:divisor]
    }
    @results = create_magic_number(opts)
    haml :booze
  end

  # Validates inputs and gets a magic number from Yahoo!
  #
  # @option [Date] rundate the date for which the magic number is generated
  # @option [Integer] divisor some integer
  # @return [Hash] a results hash
  def create_magic_number(opts = {})
    # defaults
    opts[:rundate] ||= Date.today
    opts[:divisor] ||= 4
    drinking_hash(opts[:rundate], opts[:divisor])
  end

  private

  # Generates a results hash based on Yahoo stock prices and a divisor
  #
  # @param [Date] rundate the date for which the magic number is generated
  # @param [Integer] divisor some integer
  # @return [Hash] a results hash
  def drinking_hash(rundate, divisor)
    # Validate
    raise ArgumentError, 'Cannot predict future' if opts[:rundate] > Date.today
    num = magic_number(rundate - 7)
    result = (num % divisor.to_i).zero?
    # return a hash
    { result: result, magic_number: num, divisor: divisor }
  end

  # Converts a date to a magic number
  #
  # @param [Date] run date the date
  # @return [Integer] magic number
  def magic_number(date)
    # get the stock price for Anheuser-Busch inbev
    data = YahooFinance::Client.new.historical_quotes(
      'BUD', start_date: date
    ).first
    data.open.chars.map(&:to_i).reduce(:+) +
      data.close.chars.map(&:to_i).reduce(:+) +
      date.day
  end

  # Parses the date if provided, else return today
  #
  # @option [String] date some formatted date string
  # @return [Date] the parsed date
  def parse_date(opts)
    opts[:date] ? Date.parse(opts[:date]) : Date.today
  end
end
