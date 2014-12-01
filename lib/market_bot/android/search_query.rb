module MarketBot
  module Android

    # Search query pages are extremely similar to leaderboard pages.
    # Amazingly, this inheritence hack works!
    class SearchQuery < MarketBot::Android::Leaderboard
      def initialize(query, options={})
        super(query, nil, options)
        @lang = options[:lang] || 'en'
        @page_tokens = [
            '',
            'GAEiAggU:S:ANO1ljLtUJw',
            'GAEiAggo:S:ANO1ljIeRQQ',
            'GAEiAgg8:S:ANO1ljIM1CI',
            'GAEiAghQ:S:ANO1ljLxWBY',
            'GAEiAghk:S:ANO1ljJkC4I',
            'GAEiAgh4:S:ANO1ljJfGC4',
            'GAEiAwiMAQ==:S:ANO1ljL7Yco',
            'GAEiAwigAQ==:S:ANO1ljLMTko',
            'GAEiAwi0AQ==:S:ANO1ljJ2maA'
        ]
      end

      def enqueue_update(options={}, &block)
        @callback = block
        i = 0
        @page_tokens.each do |token|
          process_page(token, i+=1)
          break if i > @max_page
        end
        self
      end

      def process_page(token, page_num)
        @pending_pages << page_num
        options = {method: :post, body: {ipf: 1, xhr: 1, hl: @lang}}.merge(@request_opts)
        if token != ''
          options[:body].merge!({start: 0, num: 0, numChildren: 0, pagTok: token})
        end
        url = "https://play.google.com/store/search?"
        url << "c=apps&"
        url << "q=#{URI.escape(identifier)}"
        request = Typhoeus::Request.new(url, options)
        request.on_complete do |response|
          # HACK: Typhoeus <= 0.4.2 returns a response, 0.5.0pre returns the request.
          response = response.response if response.is_a?(Typhoeus::Request)
          result = Leaderboard.parse(response.body)
          update_callback(result, page_num)
        end
        @hydra.queue(request)
      end
    end

  end
end
