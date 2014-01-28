# encoding: utf-8

class UrbanDictionary
	include Cinch::Plugin

	match /u(?:r(?:ban)?)? (?:([1-7]{1}) )?(.+)/i, method: :urban

	def urban(m, number, word)
		return if ignore_nick(m.user.nick)

		begin
			number ||= 1

			url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}"
			urban = Nokogiri::HTML(open(url))
			define = urban.search("//div[@class='meaning']")[number.to_i-1].text.gsub(/\s+/, ' ')

			if define.length > 250
				more = shorten_url("http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}")
				define = "#{define[0..250]}... Read more: #{more}"
			end

			m.reply "UrbanDictionary 06|\u000F #{word} 06|\u000F #{define}"
		rescue
			m.reply "UrbanDictionary 06|\u000F #{word} 06|\u000F Could not find definition"
		end
	end
end