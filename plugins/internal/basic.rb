class Basic
	include Cinch::Plugin

	# Identify with Nickserv then join channels
	listen_to :connect, method: :identify
	def identify(m)
		User("nickserv").send("identify #{$BOTPASSWORD}")
		sleep 3 # Wait for nickserv to kick in
		
		$DataBase['channels'].each do |key| 
			if key['auto_join'] == true
				Channel(key['channel']).join
				sleep 5
			end
		end
	end

	# Rename when nick becomes available
	listen_to :quit, method: :rename
	def rename(m)
		if m.user.nick == $BOTNICK
			@bot.nick = $BOTNICK
			User("nickserv").send("identify #{$BOTPASSWORD}")
		end
	end

	# Rejoin channel if kicked
	listen_to :kick
	def listen(m)
		return unless m.params[1] == @bot.nick
		sleep 3
		Channel(m.channel.name).join(m.channel.key)
	end

	match /help$/i, method: :help
	def help(m)
		m.reply "Function list: 12#{$BOTURL}\u000F Source: 12#{$BOTGIT}\u000F", true
	end

end