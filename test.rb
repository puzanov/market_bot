load 'lib/market_bot.rb'

def get_request_opts
  #proxy = get_random_working_proxy
  {
      followlocation: true,
      ssl_verifyhost: 2,
      verbose: false,
      headers: {"User-Agent" => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.3 (KHTML, like Gecko) Chrome/19.0.1063.0 Safari/536.3'}
      #proxy: proxy.host+':'+proxy.port.to_s,
      #proxyuserpwd: proxy.login+':'+proxy.password
  }
end

search = MarketBot::Android::SearchQuery::new('dentist', max_page:1, :request_opts => get_request_opts)
search.update

(0..20).each do |i|
  break if search.results.nil?
  break if search.results[i].nil?
  puts search.results[i][:market_id].downcase
  #save_rank(query, search.results[i][:market_id].downcase, i, search.results[i][:stars], MarketBot::Android::App.new(search.results[i][:market_id].downcase).update)
end
