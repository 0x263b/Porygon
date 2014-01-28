# encoding: utf-8

class Youtube
	include Cinch::Plugin

	match /y(?:outube)? (.+)/i
	match /yt (.+)/i

	def length_in_minutes(seconds)
		return nil if seconds < 0

		if seconds > 3599
			length = [seconds/3600, seconds/60 % 60, seconds % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
		elsif seconds > 59
			length = [seconds/60 % 60, seconds % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
		else
			length = "00:#{seconds.to_s.rjust(2,'0')}"
		end
	end

	def add_commas(digits)
		digits.nil? ? 0 : digits.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
	end

	def execute(m, query)
		return if ignore_nick(m.user.nick)

		begin
			query = CGI.escape(query)

			url = open("http://gdata.youtube.com/feeds/api/videos?q=#{query}&max-results=1&v=2&prettyprint=flase&alt=json").read
			hashed = JSON.parse(url)

			page_url = shorten_url("https://www.youtube.com/results?search_query=#{query}")

			name     = hashed["feed"]["entry"][0]["media$group"]["media$title"]["$t"]
			id       = hashed["feed"]["entry"][0]["media$group"]["yt$videoid"]["$t"]
			views    = hashed["feed"]["entry"][0]["yt$statistics"]["viewCount"]
			likes    = hashed["feed"]["entry"][0]["yt$rating"] && hashed["feed"]["entry"][0]["yt$rating"]["numLikes"]
			dislikes = hashed["feed"]["entry"][0]["yt$rating"] && hashed["feed"]["entry"][0]["yt$rating"]["numDislikes"]
			length   = hashed["feed"]["entry"][0]["media$group"]["yt$duration"]["seconds"]

			embed    = hashed["feed"]["entry"][0]["yt$accessControl"].find{|i| i["action"] == "embed"}

			views    = add_commas(views) 
			votes    = likes.to_i + dislikes.to_i
			rating   = ((likes.to_i+0.0)/votes)*100
			rating   = rating.round.to_s + "%"
			length   = length_in_minutes(length.to_i)

			m.reply "YouTube 05|\u000F %s 05|\u000F %s 05|\u000F %s views 05|\u000F %s 05|\u000F http://youtu.be/%s\u000F 05|\u000F More results: %s\u000F" % 
			[name, length, views, rating, id, page_url]
		rescue
			m.reply "YouTube 05|\u000F Error: Could not find video"
		end
	end
end
