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

	def shorten_url(long)
		url = URI.parse('http://mcro.us/s')
		http = Net::HTTP.new(url.host, url.port)
		response, body = http.post(url.path, long)
		return response['location']
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
			rating   = hashed["feed"]["entry"][0]["gd$rating"] && hashed["feed"]["entry"][0]["gd$rating"]["average"]
			length   = hashed["feed"]["entry"][0]["media$group"]["yt$duration"]["seconds"]

			views    = add_commas(views) 
			likes    = add_commas(likes) 
			dislikes = add_commas(dislikes)

			length   = length_in_minutes(length.to_i)

			m.reply "YouTube 5| %s 5| %s 5| %s views 5| %s/%s 5| http://youtu.be/%s 5| More results: %s" % 
			[name, length, views, likes, dislikes, id, page_url]
		rescue
			m.reply "YouTube 5| Error: Could not find video"
		end
	end
end
