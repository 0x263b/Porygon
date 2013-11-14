# encoding: utf-8

class Google
	include Cinch::Plugin

	match /g(?:oogle)? (.+)/i

	def execute(m, query)
		return if ignore_nick(m.user.nick)

		more   = shorten_url("https://www.google.com/search?q=#{URI.escape(query)}")
		images = shorten_url("https://www.google.com/search?tbm=isch&hl=en&q=#{URI.escape(query)}")

		begin
			res = open("https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{URI.escape(query)}&userip=54.225.208.28", "Referer" => "https://mcro.us/").read
			hashed = JSON.parse(res)

			for img in hashed["responseData"]["results"][0..1]
				title = img["title"].gsub(/<\/?b>/, '')
				m.reply CGI.unescape_html("Google 2| #{title} 2| #{img["url"]}")
			end 
		rescue
			nil
		end

		m.reply "Google 2| More results #{more} 2| Images: #{images}"
	end
end
