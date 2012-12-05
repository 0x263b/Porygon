class Basic
	include Cinch::Plugin

	# Identify with Nickserv then join channels
	listen_to :connect, method: :identify
	def identify(m)
		User("nickserv").send("identify #{$BOTPASSWORD}")
		sleep 1 # Wait for hostserv to kick in
		JoinDB.all.each do |this|
			Channel(this.channel).join
			sleep 1
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
		sleep 2
		Channel(m.channel.name).join(m.channel.key)
	end

	match /help$/i, method: :help
	def help(m)
		m.reply "Function list: 12#{$BOTURL} Source: 12#{$BOTGIT} Need more help? Join 12#Developers", true
	end

end