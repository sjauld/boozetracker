class App < Sinatra::Base

  include Rack::Utils

  get '/booze' do

    # which date to run
    @rundate = Date.parse(params[:date]) rescue nil || Date.today
    opts = {
      rundate: @rundate,
      divisor: params[:divisor]
    }
    @results = create_magic_number(opts)
    haml :booze
  end

  def create_magic_number(opts={})
    # Validate
    raise 'create_magic_number called with future date' if opts[:rundate] > Date.today

    # defaults
    opts[:rundate] ||= Date.today
    opts[:divisor] ||= 4

    # get the stock price for Anheuser-Busch inbev
    yahoo_client = YahooFinance::Client.new
    data = yahoo_client.historical_quotes("BUD", { start_date: opts[:rundate] - 7})
    magic_number = data.first.open.chars.map{|x| x.to_i}.reduce(:+) + data.first.close.chars.map{|x| x.to_i}.reduce(:+) + opts[:rundate].day
    result = ((magic_number % opts[:divisor].to_i) == 0 ? true : false)

    # return a hash
    {
      result: result,
      magic_number: magic_number,
      divisor: opts[:divisor]
    }

  end



end
