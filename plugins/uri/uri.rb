# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

class Uri 
	include Cinch::Plugin
	react_on :channel

	# Human readable timestamp for Twitter URLs
	def minutes_in_words(timestamp)
		minutes = (((Time.now - timestamp).abs)/60).round

		return nil if minutes < 0

		case minutes
		when 0..1      then "just now"
		when 2..59     then "#{minutes.to_s} minutes ago"
		when 60..1439        
			words = (minutes/60)
			if words > 1
				"#{words.to_s} hours ago"
			else
				"#{words.to_s} hour ago"
			end
		when 1440..11519     
			words = (minutes/1440)
			if words > 1
				"#{words.to_s} days ago"
			else
				"#{words.to_s} day ago"
			end
		when 11520..43199    
			words = (minutes/11520)
			if words > 1
				"#{words.to_s} weeks ago"
			else
				"#{words.to_s} week ago"
			end
		when 43200..525599   
			words = (minutes/43200)
			if words > 1
				"#{words.to_s} months ago"
			else
				"#{words.to_s} month ago"
			end
		else                      
			words = (minutes/525600)
			if words > 1
				"#{words.to_s} years ago"
			else
				"#{words.to_s} year ago"
			end
		end
	end

	# Only react in a channel
	listen_to :channel
	def listen(m)
		return unless ignore_nick(m.user.nick).nil? and disable_passive(m.channel.name).nil?

		URI.extract(m.message, ["http", "https"]).first(1).each do |link|

			uri = URI.parse(link)

			begin

				if(@agent.nil?)
					@agent = Mechanize.new { |agent|
						agent.user_agent_alias    = "Windows IE 7"
						agent.follow_meta_refresh = true
						agent.redirect_ok         = true
						agent.verify_mode         = OpenSSL::SSL::VERIFY_NONE
						agent.keep_alive          = false
						agent.open_timeout        = 10
						agent.read_timeout        = 10
					}
				end

				if uri.host == "t.co"
					final_uri = ''
					open(link) { |h| final_uri = h.base_uri }

					link = final_uri.to_s
					uri = URI.parse(final_uri.to_s)
				end

				begin
					page = @agent.head link
				rescue
					page = @agent.get link
				end

				# Title
				if page.header['content-type'].include? "html"

					case uri.host

					when "boards.4chan.org"

						doc = @agent.get(link)
						bang = URI::split(link)

						if bang[5].include? "/res/"

							if bang[8] != nil
								postnumber = bang[8].gsub('p', '')
							else
								postnumber = bang[5].gsub(/\/(.*)\/res\//, '')
							end

							subject   = doc.search("//div[@id='pi#{postnumber}']//span[@class='subject']").text
							poster    = doc.search("//div[@id='pi#{postnumber}']//span[@class='name']").text
							capcode   = doc.search("//div[@id='pi#{postnumber}']//strong[contains(@class,'capcode')]").text
							flag      = doc.search("//div[@id='pi#{postnumber}']//img[@class='countryFlag']/@title").text
							trip      = doc.search("//div[@id='pi#{postnumber}']//span[@class='postertrip']").text
							reply     = doc.search("//div[@id='p#{postnumber}']/blockquote").inner_html.gsub("<br>", " ").gsub("<span class=\"quote\">", "3").gsub("</span>", "").gsub(/<span class="spoiler"?[^>]*>/, "1,1").gsub("</span>", "")
							reply     = reply.gsub(/<\/?[^>]*>/, "").gsub("&gt;", ">")
							image     = doc.search("//span[@id='fT#{postnumber}']/a[1]/@href").text
							date      = doc.search("//div[@id='p#{postnumber}']//span[@class='dateTime']/@data-utc").text

							date = Time.at(date.to_i)
							date = minutes_in_words(date)

							subject = subject+" " if subject != ""
							reply = " 3| "+reply if reply != ""
							reply = reply[0..160]+" ..." if reply.length > 160
							image = " 3| File: http:"+image if image.length > 1
							flag = flag+" " if flag.length > 1
							capcode = " "+capcode if capcode.length > 1

							m.reply "4chan 3| %s3%s%s%s %s(%s) No.%s%s%s" % [subject, poster, trip, capcode, flag, date, postnumber, image, reply]

						else # Board Index Title
							page = @agent.get(link)

							begin
								title = page.title.gsub(/\s+/, ' ').strip
							rescue
								title = "text/html"
							end

							uri = URI.parse(page.uri.to_s)
							m.reply "Title 3| %s 3| %s" % [title[0..140], uri.host]
						end

					when "twitter.com"

						bang = link.split("/")
						begin
							if bang[5].include? "status"
								twurl = Nokogiri::XML(open("http://api.twitter.com/1/statuses/show.xml?id=#{bang[6]}&include_entities=true", :read_timeout=>3).read)

								tweettext   = twurl.xpath("//status/text").text.gsub(/\s+/, ' ')
								posted      = twurl.xpath("//status/created_at").text
								name        = twurl.xpath("//status/user/name").text
								screenname  = twurl.xpath("//status/user/screen_name").text

								urls        = twurl.xpath("//status/entities/urls/url")

								urls.each do |rep|
									shortened   = rep.xpath("url").text
									expanded    = rep.xpath("expanded_url").text
									tweettext   = tweettext.gsub(shortened, expanded)
								end

								time        = Time.parse(posted)
								time        = minutes_in_words(time)

								tweettext = CGI.unescape_html(tweettext)

								m.reply "Twitter 12| #{name} (@#{screenname}) 12| #{tweettext} 12| Posted #{time}"
							elsif bang[4].include? "status"
								twurl = Nokogiri::XML(open("http://api.twitter.com/1/statuses/show.xml?id=#{bang[5]}&include_entities=true", :read_timeout=>3).read)

								tweettext   = twurl.xpath("//status/text").text.gsub(/\s+/, ' ')
								posted      = twurl.xpath("//status/created_at").text
								name        = twurl.xpath("//status/user/name").text
								screenname  = twurl.xpath("//status/user/screen_name").text

								urls        = twurl.xpath("//status/entities/urls/url")

								urls.each do |rep|
									shortened   = rep.xpath("url").text
									expanded    = rep.xpath("expanded_url").text
									tweettext   = tweettext.gsub(shortened, expanded)
								end

								time        = Time.parse(posted)
								time        = minutes_in_words(time)

								tweettext = CGI.unescape_html(tweettext)

								m.reply "Twitter 12| #{name} (@#{screenname}) 12| #{tweettext} 12| Posted #{time}"
							else
								m.reply "Title 3| Twitter 3| twitter.com"
							end
						rescue
							m.reply "Title 3| Twitter 3| twitter.com"
						end

					else # Generic Title
						page = @agent.get(link)

						begin
							title = page.title.gsub(/\s+/, ' ').strip
						rescue
							title = "text/html"
						end

						uri = URI.parse(page.uri.to_s)
						m.reply "Title 3| %s 3| %s" % [title[0..140], uri.host]
					end

				# File
				else
					return unless ignore_nick(m.user.nick).nil? and disable_passive_files(m.channel.name).nil?

					fileSize = page.header['content-length'].to_i

					case fileSize
						when 0..1024 then size = (fileSize.round(1)).to_s + " B"
						when 1025..1048576 then size = ((fileSize/1024.0).round(1)).to_s + " KB"
						when 1048577..1073741824 then size = ((fileSize/1024.0/1024.0).round(1)).to_s + " MB"
						else size = ((fileSize/1024.0/1024.0/1024.0).round(1)).to_s + " GB"
					end

					filename = ''

					if page.header['content-disposition']
						filename = page.header['content-disposition'].gsub("inline;", "").gsub("filename=", "").gsub(/\s+/, ' ') + " "
					end

					type = page.header['content-type']

					uri = URI.parse(page.uri.to_s)

					m.reply "File 3| %s%s %s 3| %s" % [filename, type, size, uri.host]
				end

			rescue Mechanize::ResponseCodeError => ex
				m.reply "Title 3| #{ex.response_code} Error" 
			rescue
				nil
			end
		end
	end
end
