# encoding: utf-8

class UrbanDictionary
	include Cinch::Plugin

	match /u(?:r(?:ban)?)? (?:([1-7]{1}) )?(.+)/i, method: :urban

	def shorten_url(long)
		url = URI.parse('http://mcro.us/s')
		http = Net::HTTP.new(url.host, url.port)
		response, body = http.post(url.path, long)
		return response['location']
	end

	def urban(m, number, word)
		return if ignore_nick(m.user.nick)

		Channel("#porygon").send "#{m.channel.to_s} #{m.user.nick} | UrbanDictionary => #{word}"

		begin

			number ||= 1

			url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}"
			urban = Nokogiri::HTML(open(url))
			define = urban.search("//div[@class='definition']")[number.to_i-1].text.gsub(/\s+/, ' ')

			if define.length > 255
				more = shorten_url("http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}")
				define = "#{define[0..255]}... #{more}"
			end

			m.reply "UrbanDictionary 06| #{word} 06| #{define}"
		rescue
			m.reply "UrbanDictionary 06| #{word} 06| Could not find definition"
		end
	end
end