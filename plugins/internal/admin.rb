# encoding: utf-8

class Admin
	include Cinch::Plugin

	set :prefix, lambda{ |m| /^#{m.bot.nick},?:?\s/i}

	match /nick (.+)/i, method: :nick
	def nick(m, name)
		return unless check_admin(m.user)
		@bot.nick = name
	end


	match /quit(?: (.+))?/i, method: :quit
	def quit(m, msg)
		return unless check_admin(m.user)
		msg ||= "brb"
		bot.quit(msg)
	end


	match /msg (.+?) (.+)/i, method: :message
	def message(m, who, text)
		return unless check_admin(m.user)
		User(who).send text
	end


	match /say (.+?) (.+)/i, method: :message_channel
	def message_channel(m, chan, text)
		return unless check_admin(m.user)
		Channel(chan).send text
	end


	match /kick (\S+)(:? (.+))?/i, method: :kick
	def kick(m, nick, reason)
		return unless check_admin(m.user)
		reason ||= "Get out"
		m.channel.kick(nick, reason)
	end


	match /ban (\S+)(:? (.+))?/i, method: :ban
	def ban(m, nick, reason)
		return unless check_admin(m.user)
		reason ||= "Get out"
		baddie = User(nick);
		m.channel.ban(baddie.mask("*!*@%h"));
		m.channel.kick(nick, reason)
	end



  # Ignore users

	match /ignore (.+)/i, method: :ignore
	def ignore(m, username)
		return unless check_admin(m.user)

		begin
			if $DataBase['users'].find{ |h| h['nick'] == username.downcase }
				$DataBase['users'].find{ |h| h['nick'] == username.downcase }['ignored'] = true
			else
				$DataBase['users'] << {"nick"=> username.downcase, "admin"=> false, "ignored"=> true, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
			end

			save_DB

			m.reply "I never liked him anyway"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /unignore (.+)/i, method: :unignore
	def unignore(m, username)
		return unless check_admin(m.user)

		begin
			if $DataBase['users'].find{ |h| h['nick'] == username.downcase }
				$DataBase['users'].find{ |h| h['nick'] == username.downcase }['ignored'] = false
			else
				$DataBase['users'] << {"nick"=> username.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
			end

			save_DB

			m.reply "Sorry about that"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /list ignores/i, method: :list_ignores
	def list_ignores(m)
		return unless check_admin(m.user)
		begin

			rows = $DataBase['users'].find{ |h| h['ignored'] == true }
			rows = JSON.pretty_generate rows

			url = URI.parse('http://mcro.us/c')
			http = Net::HTTP.new(url.host, url.port)
			response, body = http.post(url.path, rows)

			m.reply response['location'], true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end



  # Make/Remove admins

	match /add admin (.+)/i, method: :add_admin
	def add_admin(m, username)
		return unless m.user.nick.downcase == $BOTOWNER

		begin
			if $DataBase['users'].find{ |h| h['nick'] == username.downcase }
				$DataBase['users'].find{ |h| h['nick'] == username.downcase }['admin'] = true
			else
				$DataBase['users'] << {"nick"=> username.downcase, "admin"=> true, "ignored"=> false, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
			end

			save_DB

			m.reply "A new master!"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /remove admin (.+)/i, method: :del_admin
	def del_admin(m, username)
		return unless m.user.nick.to_s.downcase == $BOTOWNER

		begin
			if $DataBase['users'].find{ |h| h['nick'] == username.downcase }
				$DataBase['users'].find{ |h| h['nick'] == username.downcase }['admin'] = false
			else
				$DataBase['users'] << {"nick"=> username.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
			end

			save_DB

			m.reply "I never liked him anyway"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /list admins/i, method: :list_admins
	def list_admins(m)
		return unless check_admin(m.user)
		begin
			rows = $DataBase['users'].find{ |h| h['admin'] == true }
			rows = JSON.pretty_generate rows

			url = URI.parse('http://mcro.us/c')
			http = Net::HTTP.new(url.host, url.port)
			response, body = http.post(url.path, rows)

			m.reply response['location'], true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end



  # URI ON/OFF

	match /passive on(?: (.+))?/i, method: :passive_on
	def passive_on(m, channel)
		return unless check_admin(m.user)
		channel ||= m.channel.to_s

		begin
			if $DataBase['channels'].find{ |h| h['channel'] == channel.downcase }
				$DataBase['channels'].find{ |h| h['channel'] == channel.downcase }['passive'] = true
			else
				$DataBase['channels'] << {"channel"=> channel.downcase, "auto_join"=> false, "passive"=> true, "file_info"=> true}
			end

			save_DB

			m.reply "Now reacting to URIs"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /passive off(?: (.+))?/i, method: :passive_off
	def passive_off(m, channel)
		return unless check_admin(m.user)
		channel ||= m.channel.to_s

		begin
			if $DataBase['channels'].find{ |h| h['channel'] == channel.downcase }
				$DataBase['channels'].find{ |h| h['channel'] == channel.downcase }['passive'] = false
			else
				$DataBase['channels'] << {"channel"=> channel.downcase, "auto_join"=> false, "passive"=> false, "file_info"=> false}
			end

			save_DB

			m.reply "No longer reacting to URIs"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /file info on(?: (.+))?/i, method: :passive_files_on
	def passive_files_on(m, channel)
		return unless check_admin(m.user)
		channel ||= m.channel.to_s

		begin
			if $DataBase['channels'].find{ |h| h['channel'] == channel.downcase }
				$DataBase['channels'].find{ |h| h['channel'] == channel.downcase }['file_info'] = true
			else
				$DataBase['channels'] << {"channel"=> channel.downcase, "auto_join"=> false, "passive"=> true, "file_info"=> true}
			end

			save_DB

			m.reply "Now reacting to file URIs"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /file info off(?: (.+))?/i, method: :passive_files_off
	def passive_files_off(m, channel)
		return unless check_admin(m.user)
		channel ||= m.channel.to_s

		begin
			if $DataBase['channels'].find{ |h| h['channel'] == channel.downcase }
				$DataBase['channels'].find{ |h| h['channel'] == channel.downcase }['file_info'] = false
			else
				$DataBase['channels'] << {"channel"=> channel.downcase, "auto_join"=> false, "passive"=> true, "file_info"=> false}
			end

			save_DB

			m.reply "No longer reacting to file URIs"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end



  # Join/Part channels

	match /join (.+)/i, method: :join
	def join(m, channel)
		return unless check_admin(m.user)

		begin
			$DataBase['channels'] << {"channel"=> channel.downcase, "auto_join"=> true, "passive"=> true, "file_info"=> true}

			save_DB

			Channel(channel).join
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /part(?: (.+))?/i, method: :part
	def part(m, channel)
		return unless check_admin(m.user)
		channel ||= m.channel.to_s

		begin
			$DataBase['channels'].find{ |h| h['channel'] == channel.downcase }["auto_join"] == false

			save_DB

			Channel(channel).part if channel
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /list channels/i, method: :list_channels
	def list_channels(m)
		return unless check_admin(m.user)
		begin
			rows = JSON.pretty_generate($DataBase['channels'])

			url = URI.parse('http://mcro.us/c')
			http = Net::HTTP.new(url.host, url.port)
			response, body = http.post(url.path, rows)

			m.reply response['location'], true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 



	# Last.fm 

	match /remove lastfm (.+)/i, method: :del_lastfm
	def del_lastfm(m, nick)
		return unless check_admin(m.user)
		begin
			if $DataBase['users'].find{ |h| h['nick'] == nick.downcase }
				$DataBase['users'].find{ |h| h['nick'] == nick.downcase }['lastfm'] = nil
			end

			save_DB

			m.reply "Done", true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end



	# Locations 

	match /remove location (.+)/i, method: :del_location
	def del_location(m, number)
		return unless check_admin(m.user)
		begin
			if $DataBase['users'].find{ |h| h['nick'] == nick.downcase }
				$DataBase['users'].find{ |h| h['nick'] == nick.downcase }['location'] = nil
			end

			save_DB

			m.reply "Done", true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

end