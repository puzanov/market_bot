module MarketBot
  module Android

    # Developer pages are extremely similar to leaderboard pages.
    # Amazingly, this inheritence hack works!
    #
    # BUG: This code only retrieves the first page of results.
    #      This means you will only get the first 24 apps for a developer.
    #      Some developers have hundreds of apps so this needs fixed!!!
    class Developer < MarketBot::Android::Leaderboard
      def initialize(developer, options={})
        super(developer, nil, options)
        @page_tokens = [
            '',
            'GAEiAggY:S:ANO1ljLwz5k',
            'GAEiAggw:S:ANO1ljJaDe4',
            'GAEiAghI:S:ANO1ljKqmBo',
            'GAEiAghg:S:ANO1ljLgTEE',
            'GAEiAgh4:S:ANO1ljJfGC4',
            'GAEiAwiQAQ==:S:ANO1ljLd_nA',
            'GAEiAwioAQ==:S:ANO1ljLADVM',
            'GAEiAwjAAQ==:S:ANO1ljLQ6II',
            'GAEiAwjYAQ==:S:ANO1ljL25ug',
            'GAEiAwjwAQ==:S:ANO1ljLFcVI'
        ]
      end

      def enqueue_update(options={}, &block)
        @callback = block
        i = 0
        @page_tokens.each do |token|
          process_page(token, i+=1)
        end
        self
      end

      def process_page(token, page_num)
        @pending_pages << page_num
        options = {method: :post, body: {start: 0, num: 24, numChildren: 0, pagTok: token, ipf: 1, xhr: 1}}.merge(@request_opts)
        url = "https://play.google.com/store/apps/developer?"
        url << "id=#{URI.escape(identifier)}&"
        url << "hl=en"
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
