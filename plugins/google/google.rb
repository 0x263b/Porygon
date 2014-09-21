# encoding: utf-8

class Google
	include Cinch::Plugin

	match /g(?:oogle)? (.+)/i

	def execute(m, query)
		return if ignore_nick(m.user.nick)

		more   = shorten_url("https://encrypted.google.com/search?q=#{CGI.escape(query)}")
		images = shorten_url("https://encrypted.google.com/search?q=#{CGI.escape(query)}&tbm=isch")

		begin
			res = open("https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{CGI.escape(query)}").read
			# You may need to add your server IP and refer to this query, eg:
			# res = open("https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{CGI.escape(query)}&userip=31.220.24.71", "Referer" => "http://tfwnogf.info/").read
			hashed = JSON.parse(res)

			for img in hashed["responseData"]["results"][0..1]
				title = img["title"].gsub(/<b>/, '').gsub(/<\/b>/, "\u000F")
				m.reply CGI.unescape_html("Google 02|\u000F #{title} 02|\u000F #{CGI.unescape(img["url"])}\u000F")
			end 
		rescue
			nil
		end

		m.reply "Google 02|\u000F More results #{more}\u000F 02|\u000F Images: #{images}\u000F"
	end
end
