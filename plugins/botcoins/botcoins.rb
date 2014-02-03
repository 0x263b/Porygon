class BotCoins
	include Cinch::Plugin
	
	def initialize(*args)
		super
		@time = Hash.new Time.now.to_i
	end


	match /botcoins/i, method: :total_coins, :react_on => :channel
	def total_coins(m)
		return if ignore_nick(m.user.nick)

		coins_in_circulation = 0

		$DataBase['users'].each do |key| 
			coins_in_circulation += key['botcoins']
		end

		coins_in_circulation = add_commas(coins_in_circulation.to_s)

		m.reply "There are currently #{coins_in_circulation}\u000F botcoins in circulation"
	end


	match /mine/i, method: :mine, :react_on => :channel
	def mine(m)
		return if ignore_nick(m.user.nick) or check_time(m.user.nick)
		update_time(m.user.nick)
		mined = exponential(5)

		if $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += mined
		else
			$DataBase['users'] << {"nick"=> m.user.nick.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += mined		
		end

		save_DB

		balance = $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins']

		m.user.notice "You have mined #{mined} botcoin(s), giving you a total of #{balance}"
	end


	match /balance(?: (\S+))?/i, method: :balance, :react_on => :channel
	def balance(m, nick)
		return if ignore_nick(m.user.nick)

		nick ||= m.user.nick

		if $DataBase['users'].find{ |h| h['nick'] == nick.downcase }
			balance = $DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins']
			m.reply "#{nick}\u000F has #{balance}\u000F botcoins"
		else
			m.reply "#{nick}\u000F doesn't have any botcoins"
		end
	end


	match /loot (\S+)/i, method: :loot, :react_on => :channel
	def loot(m, nick)
		return if ignore_nick(m.user.nick) or check_time(m.user.nick) or (nick == m.user.nick)
		update_time(m.user.nick)

		if (nick.downcase == bot.nick.downcase)
			# Don't loot the bot!
			m.user.notice "1,8[!] The Federal Bureau of Investigation has logged a record of this chat along with the IP addresses of the participants due to potential violations of U.S. law. Reference no. 8429l271. 1,8[!]"
		elsif $DataBase['users'].find{ |h| h['nick'] == nick.downcase }
			# Are you looting yourself?
			# Do you have over 10 coins?
			return if $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase } and $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] <= 9

			outcome = Random.rand(10)

			case outcome
			when 0
				# Successful theft
				if $DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins'] >= 1
					target = $DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins']

					theft = exponential(target/5)

					$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += theft
					$DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins'] -= theft
					
					m.user.notice "You successfully hack into #{nick}'s botcoin account and transfer #{theft}."
				else
					m.user.notice "You successfully hack into #{nick}'s botcoin account only to find that it's empty! FUCKING POORFAGS!"
				end
			when 1..2
				# Caught by the FBI
				fine = exponential(15)
				$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] -= fine
				$DataBase['users'].find{ |h| h['nick'] == bot.nick.downcase }['botcoins'] += fine

				m.user.notice "The bank becomes aware of your attempts and alerts the police. The courts fine you #{fine} botcoins."
			when 3
				# Get looted while lotting
				assailant = $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins']
				loss = exponential(assailant/8)
				$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] -= loss
				$DataBase['users'].find{ |h| h['nick'] == bot.nick.downcase }['botcoins'] += loss

				m.user.notice "While you struggle at guessing #{nick}'s PIN an unidentified cybercriminal compromizes your account and gets away with #{loss} botcoins."
			when 4..9
				# Nothing happens
				m.user.notice "You attempt to gain access to #{nick}'s account but fail to get past the login screen"
			end
		else
			m.user.notice "#{nick} doesn't have any botcoins!"
		end

		save_DB
	end


	match /give (\S+) (\d+)/i, method: :give, :react_on => :channel
	def give(m, nick, amount)
		return if ignore_nick(m.user.nick) or (nick == m.user.nick)

		amount = amount.to_i
		m.user.refresh unless m.user.authed?
		if $DataBase['users'].find{ |h| h['nick'] == m.user.authname.downcase }
			return if ($DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] < amount)

			if $DataBase['users'].find{ |h| h['nick'] == nick.downcase }
				$DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins'] += amount
			else
				$DataBase['users'] << {"nick"=> nick.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
				$DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins'] += amount
			end

			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] -= amount

			m.user.notice "Transferred #{amount} botcoins to #{nick}"
			User(nick).notice "Received #{amount} botcoins from #{m.user.nick}"
			save_DB
		else
			m.user.notice "I'm afraid I can't let you do that, \"#{m.user.nick}\""
		end
	end


	match /kick (\S+)/i, method: :kick_coins, :react_on => :channel
	def kick_coins(m, nick)
		return if ignore_nick(m.user.nick) or (nick == bot.nick)

		m.user.refresh unless m.user.authed?
		if $DataBase['users'].find{ |h| h['nick'] == m.user.authname.downcase }
			return if ($DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] < 80)
			baddie = User(nick)
			m.channel.ban(baddie.mask("*!*@%h"))
			m.channel.kick(nick, "Requested (#{m.user.nick})")
			sleep 5
			m.channel.unban(baddie.mask("*!*@%h"))

			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] -= 80

			m.user.notice "The deed is done"
			save_DB
		end
	end


	match /ban (\S+)/i, method: :ban_coins, :react_on => :channel
	def ban_coins(m, nick)
		return if ignore_nick(m.user.nick) or (nick == bot.nick)

		m.user.refresh unless m.user.authed?
		if $DataBase['users'].find{ |h| h['nick'] == m.user.authname.downcase }
			return if ($DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] < 250)
			baddie = User(nick)
			m.channel.ban(baddie.mask("*!*@%h"))
			m.channel.kick(nick, "Requested (#{m.user.nick})")

			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] -= 250

			m.user.notice "The deed is done"
			save_DB
		end
	end


	match /topic (.+)/i, method: :topic_coins, :react_on => :channel
	def topic_coins(m, message)
		return if ignore_nick(m.user.nick)

		m.user.refresh unless m.user.authed?
		if $DataBase['users'].find{ |h| h['nick'] == m.user.authname.downcase }
			return if ($DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] < 30)
			m.channel.topic= message

			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] -= 30

			m.user.notice "The deed is done"
			save_DB
		end
	end


	def update_time(nick)
		@time[nick.downcase] = (Time.now.to_i + 30)
	end


	def check_time(nick)
		nick = nick.downcase

		if @time.key?(nick) == true
			Time.now.to_i > @time[nick] ? (return false) : (return true)
		else
			update_time(nick)
			return false
		end
	end

	def exponential(mean)
		(-mean * Math.log(rand)).ceil if mean > 0
	end

	def add_commas(digits)
		digits.nil? ? 0 : digits.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
	end

end
