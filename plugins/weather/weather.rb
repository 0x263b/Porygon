# encoding: utf-8

class Weather
	include Cinch::Plugin

	# Check the DB for stored locations

	def get_location(m, param) 
		if param == '' || param.nil?
			if $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }
				location = $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['location']
			
				if location.nil?
					m.reply "location not provided nor on file. Use -set location location\u000F to save your location."
					return nil
				else
					return location
				end
			else
				$DataBase['users'] << {"nick"=> m.user.nick.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
					m.reply "location not provided nor on file. Use -set location location\u000F to save your location."
				return nil
			end
		else
			return param.strip
		end
	end 

	# Yahoo weather
	match /w(?:e(?:ather)?)?(?: (.+))?$/iu, method: :yahoo_weather
	def yahoo_weather(m, loc = nil)
		return if ignore_nick(m.user.nick)

		location = get_location(m, loc)
		return if location.nil?

		begin
			argument = CGI.escape(location)

			# Yahoo weather requires a WOEID
			# This service lets you look up a location and gives a WOEID back
			url = Nokogiri::XML(open("http://where.yahooapis.com/v1/places.q('#{argument}')?appid=NNX2aErV34GtMtnxo1hu1Bk_aIpuf6M3olFfsSCuioHahzWMcgHAKkFP3lBwBxOiAz1TVpQ-").read)
			woeid       = url.css('woeid').text
			country     = url.css('country')[0]['code']

			# Since amerifats still live in the 1800s we have to give them Fahrenheit
			if country == "US"
				unit   = "f"
				units  = "\u2109"
				wunits = "mph"
			else
				unit   = "c"
				units  = "\u2103"
				wunits = "km/h"
			end


			url = Nokogiri::XML(open("http://weather.yahooapis.com/forecastrss?w=#{woeid}&u=#{unit}").read)
			city        = url.xpath("//yweather:location/@city")
			region      = url.xpath("//yweather:location/@region")
			condition   = url.xpath("//yweather:condition/@text")
			temp        = url.xpath("//yweather:condition/@temp")
			humidity    = url.xpath("//yweather:atmosphere/@humidity")
			speed       = url.xpath("//yweather:wind/@speed")

			day_one     = url.xpath("//yweather:forecast[1]/@day")
			high_one    = url.xpath("//yweather:forecast[1]/@high")
			low_one     = url.xpath("//yweather:forecast[1]/@low")
			text_one    = url.xpath("//yweather:forecast[1]/@text")

			day_two     = url.xpath("//yweather:forecast[2]/@day")
			high_two    = url.xpath("//yweather:forecast[2]/@high")
			low_two     = url.xpath("//yweather:forecast[2]/@low")
			text_two    = url.xpath("//yweather:forecast[2]/@text")

			return unless city.to_s.length > 1

			region = ", "+region.to_s if region.to_s.length > 0

			text = "%s%s 02|\u000F %s %s%s. Humidity: %s%s. Wind: %s %s 02|\u000F %s\u000F: %s %s%s/%s%s 02|\u000F %s\u000F: %s %s%s/%s%s" % 
					[city, region, condition, temp, units, humidity, '%', speed, wunits, day_one, text_one, high_one, units, low_one, units, day_two, text_two, high_two, units, low_two, units]

		rescue 
			text = "Error getting weather for #{loc}"
		end
		m.reply "Weather 02|\u000F #{text}"
	end

end
