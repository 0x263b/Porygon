class BotCoins
	include Cinch::Plugin
	
	def initialize(*args)
		super
		@time = Hash.new Time.now.to_i
	end


	match /mine/i, method: :mine, :react_on => :channel
	def mine(m)
		puts 'mining'
		return if ignore_nick(m.user.nick) or check_time(m.user.nick)

		update_time(m.user.nick)

		mined = exponential

		if $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += mined
		else
			$DataBase['users'] << {"nick"=> item.nick.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += mined		
		end

		save_DB

		balance = $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins']

		m.user.notice "You have mined #{mined} botcoin(s), giving you a total of #{balance}"
	end

	match /balance(?: (.+))?/i, method: :balance, :react_on => :channel
	def balance(m, nick)
		return if ignore_nick(m.user.nick)

		nick ||= m.user.nick

		if $DataBase['users'].find{ |h| h['nick'] == nick.downcase }
			balance = $DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins']
			m.reply "#{nick} has mined #{balance} botcoins"
		else
			$DataBase['users'] << {"nick"=> nick.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
			balance = $DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins']
			m.reply "#{nick} has mined #{balance} botcoins"
		end
	end

	match /loot (.+)/i, method: :loot, :react_on => :channel
	def loot(m, nick)
		return if ignore_nick(m.user.nick) or check_time(m.user.nick)

		update_time(m.user.nick)

		theft = exponential

		if $DataBase['users'].find{ |h| h['nick'] == nick.downcase }
			if $DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins'] >= 0
				$DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins'] -= theft
				$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += theft

				m.user.notice "You stole #{theft} botcoins from #{nick}!"
			else
				m.user.notice "#{nick} is out of botcoins!"
			end
		else
			$DataBase['users'] << {"nick"=> nick.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
			$DataBase['users'].find{ |h| h['nick'] == nick.downcase }['botcoins'] -= theft
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += theft

			m.user.notice "You stole #{theft} botcoins from #{nick}!"
		end

		save_DB
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

	def exponential
		(-5 * Math.log(rand)).ceil
	end
end
