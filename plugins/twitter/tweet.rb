# encoding: utf-8
class Tweet
	include Cinch::Plugin

	def prepare_access_token(oauth_token, oauth_token_secret)
		consumer = OAuth::Consumer.new($TWITTER_CONSUMER_KEY, $TWITTER_CONSUMER_SECRET, {:site => "http://api.twitter.com", :scheme => :header })
		token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
		access_token = OAuth::AccessToken.from_hash(consumer, token_hash)

		return access_token
	end

	# Since mnn.im links expire, we'll use waa.ai for these links
	def akari_shorten(url)
		url = open("http://api.waa.ai/?url=#{url}&response=json").read
		hashed = JSON.parse(url)
		return hashed["shortURL"]
	end

	$lastline = Hash.new(Time.now.to_i)

	listen_to :channel # Only react in a channel
	def listen(m)
		return unless Time.now.to_i > $lastline[m.channel]
		return if ignore_nick(m.user.nick) or uri_disabled(m.channel.name)

		begin

			channel = m.channel.to_s

			charcount = m.user.nick.length + channel.length

			message = m.message
			message = message[0..136-charcount] if message.length > 136 - charcount # Trim the message if it's too long
			message = message.gsub(/\x1f|\x02|\x12|\x0f|\x16|\x03(?:\d{1,2}(?:,\d{1,2})?)?/, '') # Strip color codes, etc.
			message = message.gsub(/[\n\f\r\t\v]/, '') # Strip weird spaces

			URI.extract(message, ["http", "https"]).each do |link|
				message = message.gsub(link, akari_shorten(link))
			end

			tweettext = "#{m.user.nick}: #{message} #{channel}"

			# Get the access token and post
			access_token = prepare_access_token($TWITTER_ACCESS_TOKEN, $TWITTER_ACCESS_TOKEN_SECRET)
			access_token.post("https://api.twitter.com/1.1/statuses/update.json", {:status => tweettext})

			$lastline[m.channel] = Time.now.to_i + 600
		rescue
			nil
		end
	end
end