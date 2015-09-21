class App < Sinatra::Base

  include Rack::Utils

  get '/' do
    # which date to run
    @rundate = Date.parse(params[:date]) rescue nil || Date.today
    if @rundate > Date.today
      redirect to('/'), error: 'Sorry time traveller, we can\'t predict the future'
    end
    @divisor = params[:divisor] || 4
    # get the stock price for Anheuser-Busch inbev
    yahoo_client = YahooFinance::Client.new
    data = yahoo_client.historical_quotes("BUD", { start_date: @rundate - 7})
    @magic_number = data.first.open.chars.map{|x| x.to_i}.reduce(:+) + data.first.close.chars.map{|x| x.to_i}.reduce(:+) + @rundate.day
    @result = ((@magic_number % @divisor.to_i) == 0 ? true : false)
    haml :index
  end

  get '/secret-google-stuff' do
    haml :secret
  end



end
