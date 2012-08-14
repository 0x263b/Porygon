# encoding: utf-8

class Google
	include Cinch::Plugin

	match /g(?:oogle)? (.+)/i

	def execute(m, query)
		return unless ignore_nick(m.user.nick).nil?

		begin

			res = open("https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{URI.escape(query)}&userip=209.141.33.144", "Referer" => "https://undef.tv/").read
			hashed = JSON.parse(res)

			for img in hashed["responseData"]["results"][0..1]
				title = img["title"].gsub(/<\/?b>/, '')
				m.reply CGI.unescape_html("Google 2| #{title} 2| #{img["url"]}")
			end 

		rescue
			nil
		end

		@bitly = Bitly.new($BITLYUSER, $BITLYAPI)

		more   = @bitly.shorten("https://encrypted.google.com/search?hl=en&q=#{URI.escape(query)}")
		images = @bitly.shorten("https://www.google.com/search?tbm=isch&hl=en&q=#{URI.escape(query)}")

		m.reply "Google 2| More results #{more.shorten} 2| Images: #{images.shorten}"
	end

end
