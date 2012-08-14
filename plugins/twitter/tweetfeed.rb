# 
# Currently disabled until I add multi-channel support
#
#


CHANNEL = "#soshichan"
#TWITTER_USER = ""

class TweetFeed
	include Cinch::Plugin

	timer 120, method: :send_last_status

	def initialize(*args)
		super
		@last_sent_id = nil
	end

	def send_last_status

		begin
			url = Nokogiri::XML(open("https://api.twitter.com/1/lists/statuses.xml?slug=soshibot&owner_screen_name=soshibro&per_page=1&page=1&include_entities=true", :read_timeout=>3).read)
			#url = Nokogiri::XML(open("http://api.twitter.com/1/statuses/user_timeline.xml?screen_name=#{TWITTER_USER}&count=1&include_rts=true&exclude_replies=true", :read_timeout=>3).read)

			statusId    = url.xpath("//status/id").text
			tweettext   = url.xpath("//status/text").text.gsub(/\s+/, ' ')
			name        = url.xpath("//statuses/status/user/name").text
			screenname  = url.xpath("//statuses/status/user/screen_name").text

			urls        = url.xpath("//status/entities/urls/url")

			urls.each do |rep|
				shortened   = rep.xpath("url").text
				expanded    = rep.xpath("expanded_url").text
				tweettext   = tweettext.gsub(shortened, expanded)
			end

			# Because twitter lists skip over RTs
			# the xml file will be blank if the latest tweet is an RT
			# instead of showing the tweet before that
			# GOOD WORK TWITTER
			return unless tweettext.length > 0

			if @last_sent_id.nil?
				# Skip the first message from so we don't spam every time the bot reconnects
				@last_sent_id = statusId
			elsif @last_sent_id != statusId

				@last_sent_id = statusId

				Channel(CHANNEL).send "Twitter Feed 12| #{name} (@#{screenname}) 12| #{tweettext}"
			end
		rescue
			nil
		end
	end

end
