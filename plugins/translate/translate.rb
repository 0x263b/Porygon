# encoding: utf-8

class Translate
	include Cinch::Plugin

	match /t(?:r(?:anslate)?)? ([a-zA-Z-]{2,6}) ([a-zA-Z-]{2,6}) (.*)/iu

	def execute(m, from, to, message)
		return if ignore_nick(m.user.nick)

		# Make link to Google Translate as a backup
		google_url = shorten_url("http://translate.google.com/\##{from}/#{to}/#{CGI.escape(message)}")

		begin
			url = open("https://api.datamarket.azure.com/Data.ashx/Bing/MicrosoftTranslator/Translate?Text=%27#{CGI.escape(message)}%27&To=%27#{to}%27&From=%27#{from}%27&$top=100&$format=Atom", :http_basic_authentication=>[$AZUREU, $AZUREP])
			url = Nokogiri::XML(url)

			result = url.xpath("//d:Text").text

			m.reply "Translate 11|\u000F #{google_url} 11|\u000F #{from}=>#{to} 11| #{result}"
		rescue
			m.reply "Translate 11|\u000F #{google_url} 11|\u000F Error: Could not get translation"
		end
	end
end