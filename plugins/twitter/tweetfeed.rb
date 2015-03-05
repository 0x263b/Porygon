# encoding: utf-8

class TweetFeed
	include Cinch::Plugin

	CHANNEL = ""
	TWITTER_USER = ""
	TWITTER_LIST = ""

	timer 120, method: :send_last_status

	def initialize(*args)
		super
		@last_sent_id = nil
	end

	def prepare_access_token(oauth_token, oauth_token_secret)
		consumer = OAuth::Consumer.new($TWITTER_CONSUMER_KEY, $TWITTER_CONSUMER_SECRET, {:site => "http://api.twitter.com", :scheme => :header })
		token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
		access_token = OAuth::AccessToken.from_hash(consumer, token_hash)

		return access_token
	end

	def send_last_status
		begin
			access_token = prepare_access_token($TWITTER_ACCESS_TOKEN, $TWITTER_ACCESS_TOKEN_SECRET)

			response = access_token.request(:get, "https://api.twitter.com/1.1/lists/statuses.json?slug=#{TWITTER_LIST}&owner_screen_name=#{TWITTER_USER}&count=1&include_rts=true")
			parsed_response = JSON.parse(response.body)

			status_id   = parsed_response[0]["id"]
			name        = parsed_response[0]["user"]["name"]
			screenname  = parsed_response[0]["user"]["screen_name"]

			if parsed_response[0].has_key?("retweeted_status")
				tweettext = parsed_response[0]["retweeted_status"]["text"].gsub(/\s+/, ' ')
				urls      = parsed_response[0]["retweeted_status"]["entities"]["urls"]
			else
				tweettext = parsed_response[0]["text"].gsub(/\s+/, ' ')
				urls      = parsed_response[0]["entities"]["urls"]
			end

			urls.each do |rep|
				short = rep["url"]
				long  = rep["expanded_url"]
				tweettext = tweettext.gsub(short, long)
			end

			if parsed_response[0]["entities"].has_key?("media")
				media = parsed_response[0]["extended_entities"]["media"][0]

				if (media["type"] == "animated_gif" or media["type"] == "video")
					image_url = media["video_info"]["variants"][0]["url"]
					image_url = shorten_url(image_url)
				else
					image_url = media["media_url_https"]
					image_url = shorten_url(image_url + ":orig")
				end

				image_tco = media["url"]
				tweettext = tweettext.gsub(image_tco, image_url)
			end

			tweettext = CGI.unescape_html(tweettext)

			return unless tweettext.length > 0

			if @last_sent_id.nil?
				# Skip the first message from so we don't spam every time the bot reconnects
				@last_sent_id = status_id
			elsif @last_sent_id != status_id

				@last_sent_id = status_id

				Channel(CHANNEL).send "Twitter Feed 12| #{name} (@#{screenname}) 12| #{tweettext}"
			end
		rescue
			nil
		end
	end

end
