# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

class Weather
	include Cinch::Plugin

	# Check the DB for stored locations

	def get_location(m, param) 
		if param == '' || param.nil?
			location = LocationDB.first(:nick => m.user.nick.downcase)
			if location.nil?
				m.reply "location not provided nor on file. Use :set location location to save your location."
				return nil
			else
				return location.location
			end
		else
			return param.strip
		end
	end 


	match /w(?:e(?:ather)?)?(?: (.+))?$/iu, method: :yahoo_weather
	def yahoo_weather(m, loc = nil)
		return unless ignore_nick(m.user.nick).nil?

		location = get_location(m, loc)
		return if location.nil?

		begin
			argument = URI.escape(location)

			# Yahoo weather requires a WOEID
			# This service lets you look up a location and gives a WOEID back
			url = Nokogiri::XML(open("http://where.yahooapis.com/v1/places.q('#{argument}')?appid=NNX2aErV34GtMtnxo1hu1Bk_aIpuf6M3olFfsSCuioHahzWMcgHAKkFP3lBwBxOiAz1TVpQ-").read)
			woeid       = url.css('woeid').text

			url = Nokogiri::XML(open("http://weather.yahooapis.com/forecastrss?w=#{woeid}&u=c").read)
			city        = url.xpath("//yweather:location/@city")
			region      = url.xpath("//yweather:location/@region")
			condition   = url.xpath("//yweather:condition/@text")
			temp        = url.xpath("//yweather:condition/@temp")
			#chill       = url.xpath("//yweather:wind/@chill")
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

			text = "%s%s 2| %s %s\u00B0C. Humidity: %s%s. Wind: %s km/h 2| %s: %s %s\u00B0C/%s\u00B0C 2| %s: %s %s\u00B0C/%s\u00B0C" % 
					[city, region, condition, temp, humidity, '%', speed, day_one, text_one, high_one, low_one, day_two, text_two, high_two, low_two]

		rescue 
			text = "Error getting weather for #{loc}"
		end
		m.reply "Weather 2| #{text}"
	end

end
