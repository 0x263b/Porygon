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

	def execute(m, query)
		return unless ignore_nick(m.user.nick).nil?

		begin
			bitly = Bitly.new($BITLYUSER, $BITLYAPI)

			query = URI.escape(query)

			@url = open("http://gdata.youtube.com/feeds/api/videos?q=#{query}&max-results=3&v=2&prettyprint=true&alt=rss")
			@url = Nokogiri::XML(@url)

			@page_url = bitly.shorten("https://www.youtube.com/results?search_query=#{query}")

			def search(number)
				return if @url.xpath("//item[#{number}]/title").text.length < 1

				name       = @url.xpath("//item[#{number}]/title").text
				id         = @url.xpath("//item[#{number}]/media:group/yt:videoid").text
				views      = @url.xpath("//item[#{number}]/yt:statistics/@viewCount").text
				likes      = @url.xpath("//item[#{number}]/yt:rating/@numLikes").text
				dislikes   = @url.xpath("//item[#{number}]/yt:rating/@numDislikes").text
				rating     = @url.xpath("//item[#{number}]/gd:rating/@average").text
				length     = @url.xpath("//item[#{number}]/media:group/yt:duration/@seconds").text

				views      = views.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
				likes      = likes.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
				dislikes   = dislikes.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse

				length = length_in_minutes(length.to_i)

				"YouTube 5| \"%s\" 5| %s 5| %s views 5| %s/5 (%s|%s) 5| http://youtu.be/%s 5| More results: %s" % [name, length, views, rating[0..2], likes, dislikes, id, @page_url.shorten]
			end
		
			m.reply search(1)
		rescue
			m.reply "YouTube 4| Error: Could not find video"
		end
	end
end
