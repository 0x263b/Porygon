# encoding: utf-8

class Translate
	include Cinch::Plugin

	match /t(?:r(?:anslate)?)? ([a-zA-Z-]{2,6}) ([a-zA-Z-]{2,6}) (.*)/iu

	def execute(m, from, to, message)
		return if ignore_nick(m.user.nick)

		begin
			url = open("https://api.datamarket.azure.com/Data.ashx/Bing/MicrosoftTranslator/Translate?Text=%27#{URI.escape(message)}%27&To=%27#{to}%27&From=%27#{from}%27&$top=100&$format=Atom", :http_basic_authentication=>[$AZUREU, $AZUREP])
			url = Nokogiri::XML(url)

			result = url.xpath("//d:Text").text

			m.reply "Translate 11| #{from}=>#{to} 11| #{result}"
		rescue
			m.reply "Translate 11| Error: Could not get translation"
		end
	end
end