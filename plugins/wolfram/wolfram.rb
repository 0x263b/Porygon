# encoding: utf-8

class Wolfram
	include Cinch::Plugin

	match /wa (.+)$/i

	def execute(m, query)
		return unless ignore_nick(m.user.nick).nil?
		begin

			@bitly = Bitly.new($BITLYUSER, $BITLYAPI)
			 
			@url = open("http://api.wolframalpha.com/v2/query?appid=#{$WOLFRAMAPI}&input=#{CGI.escape(query)}")
			@url = Nokogiri::XML(@url)

			output = ""

			input     = @url.xpath("//pod[@id='Input']/subpod/plaintext").text.gsub(/\s+/, ' ')
			output    = @url.xpath("//pod[@title='Result']/subpod/plaintext").text.gsub(/\s+/, ' ')

			if output.length < 1
				output    = @url.xpath("//pod[@title='Results']/subpod[1]/plaintext").text.gsub(/\s+/, ' ')
			end

			input  = input[0..140]+"..."  if input.length > 140
			output = output[0..140]+"..." if output.length > 140

			if output.length < 1 and input.length > 1
				reply = input + " => Can not render answer. Check link"
			elsif output.length < 1 and input.length < 1
				reply = "Fucked if I know"
			else
				reply = input + " => " + output
			end

			more  = @bitly.shorten("http://www.wolframalpha.com/input/?i=#{CGI.escape(query)}")

			m.reply "Wolfram 7| %s 7| More info: %s" % [reply, more.shorten]
		rescue
			m.reply "Wolfram 7| Error"
		end
	end
end