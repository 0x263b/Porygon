# encoding: utf-8

class UrbanDictionary
	include Cinch::Plugin

	match /u(?:r(?:ban)?)? (?:([1-7]{1}) )?(.+)/i, method: :urban

	def urban(m, number, word)
		return if ignore_nick(m.user.nick)

		begin
			number ||= 1

			url = open("http://api.urbandictionary.com/v0/define?term=#{CGI.escape(word)}").read
			hashed = JSON.parse(url)

			define = hashed["list"][number.to_i-1]["definition"].gsub(/\s+/, ' ')
			more = shorten_url(hashed["list"][number.to_i-1]["permalink"])

			if define.length > 200
				define = "#{define[0..200]}..."
			end

			m.reply "UrbanDictionary 06|\u000F #{word} 06|\u000F #{more} 06|\u000F #{define}"
		rescue
			m.reply "UrbanDictionary 06|\u000F #{word} 06|\u000F Could not find definition"
		end
	end
end