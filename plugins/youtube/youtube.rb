# encoding: utf-8

class Youtube
	include Cinch::Plugin

	match /y(?:outube)? (.+)/i
	match /yt (.+)/i

	def length_in_minutes(seconds=0)
		seconds = Duration.new(seconds).to_i

		if seconds > 3599
			length = [seconds/3600, seconds/60 % 60, seconds % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
		elsif seconds > 59
			length = [seconds/60 % 60, seconds % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
		else
			length = "00:#{seconds.to_s.rjust(2,'0')}"
		end

		return length
	end

	def add_commas(digits)
		digits.nil? ? 0 : digits.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
	end

	def execute(m, query)
		return if ignore_nick(m.user.nick)

		begin
			query = CGI.escape(query)
			url = open("https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=#{query}&key=#{$YOUTUBE_API}").read
			hashed = JSON.parse(url)

			page_url = shorten_url("https://www.youtube.com/results?search_query=#{query}")

			name     = hashed["items"][0]["snippet"]["title"]
			id       = hashed["items"][0]["id"]["videoId"]

			url = open("https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&id=#{id}&key=#{$YOUTUBE_API}").read
			hashed = JSON.parse(url)

			views    = hashed["items"][0]["statistics"]["viewCount"] || 0
			likes    = hashed["items"][0]["statistics"]["likeCount"] || 0
			dislikes = hashed["items"][0]["statistics"]["dislikeCount"] || 0
			length   = hashed["items"][0]["contentDetails"]["duration"] || "PT1M1S"

			views    = add_commas(views) 
			votes    = likes.to_i + dislikes.to_i
			rating   = (votes > 0 ? (((likes.to_i+0.0)/votes.to_i)*100) : 0.0)
			rating   = rating.round.to_s + "%"
			length   = length_in_minutes(length)

			m.reply "YouTube 05|\u000F %s 05|\u000F %s 05|\u000F %s views 05|\u000F %s 05|\u000F https://youtu.be/%s\u000F 05|\u000F More results: %s\u000F" % 
			[name, length, views, rating, id, page_url]
		rescue
			m.reply "YouTube 05|\u000F Error: Could not find video"
		end
	end
end
