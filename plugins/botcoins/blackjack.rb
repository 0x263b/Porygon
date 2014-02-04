# encoding: utf-8

class BlackJack
	include Cinch::Plugin

	def initialize(*args)
		super
		@hand = Hash.new

		# our decks of cards
		@deck = [
			["A", "04,00A\u2665\u000F"], [2, "04,002\u2665\u000F"], [3, "04,003\u2665\u000F"], [4, "04,004\u2665\u000F"], [5, "04,005\u2665\u000F"], [6, "04,006\u2665\u000F"], [7, "04,007\u2665\u000F"], [8, "04,008\u2665\u000F"], [9, "04,009\u2665\u000F"], [10, "04,0010\u2665\u000F"], ["J", "04,00J\u2665\u000F"], ["Q", "04,00Q\u2665\u000F"], ["K", "04,00K\u2665\u000F"], # Hearts
			["A", "01,00A\u2663\u000F"], [2, "01,002\u2663\u000F"], [3, "01,003\u2663\u000F"], [4, "01,004\u2663\u000F"], [5, "01,005\u2663\u000F"], [6, "01,006\u2663\u000F"], [7, "01,007\u2663\u000F"], [8, "01,008\u2663\u000F"], [9, "01,009\u2663\u000F"], [10, "01,0010\u2663\u000F"], ["J", "01,00J\u2663\u000F"], ["Q", "01,00Q\u2663\u000F"], ["K", "01,00K\u2663\u000F"], # Clubs
			["A", "01,00A\u2660\u000F"], [2, "01,002\u2660\u000F"], [3, "01,003\u2660\u000F"], [4, "01,004\u2660\u000F"], [5, "01,005\u2660\u000F"], [6, "01,006\u2660\u000F"], [7, "01,007\u2660\u000F"], [8, "01,008\u2660\u000F"], [9, "01,009\u2660\u000F"], [10, "01,0010\u2660\u000F"], ["J", "01,00J\u2660\u000F"], ["Q", "01,00Q\u2660\u000F"], ["K", "01,00K\u2660\u000F"], # Spades
			["A", "04,00A\u2666\u000F"], [2, "04,002\u2666\u000F"], [3, "04,003\u2666\u000F"], [4, "04,004\u2666\u000F"], [5, "04,005\u2666\u000F"], [6, "04,006\u2666\u000F"], [7, "04,007\u2666\u000F"], [8, "04,008\u2666\u000F"], [9, "04,009\u2666\u000F"], [10, "04,0010\u2666\u000F"], ["J", "04,00J\u2666\u000F"], ["Q", "04,00Q\u2666\u000F"], ["K", "04,00K\u2666\u000F"]] # Diamonds

	end


	# Counts your points
	def hand_count(hand)
		aces = 0
		total = 0

		hand.each do |card|
			if card[0] == "A"
				aces += 1
				total += 11
			elsif card[0] =~ /^[JQK]/
				total += 10
			else
				total += card[0]
			end
		end

		# Drop aces to 1 if we bust
		while (total > 21) and (aces > 0)
			aces -= 1
			total -= 10
		end

		return total
	end

	# Counts aces in your hand (WIP)
	def aces_count(hand)
		aces = 0

		hand.each do |card|
			if card[0] == "A"
				aces += 1
			end
		end

		return aces
	end

	# Renders your hand
	def show_hand(hand)
		showing_hand = ""

		hand.each do |card|
			showing_hand = showing_hand + card[1].to_s + " "
		end

		return showing_hand
	end

	# Start a game
	match /blackjack (\d+)/i, method: :blackjack_bet, :react_on => :channel
	def blackjack_bet (m, bet)
		return if ignore_nick(m.user.nick) # ignore ignored users
		m.user.refresh unless m.user.authed? # ignore unidentified users

		@hand.delete(m.user.nick)
		bet = bet.to_i

		if (bet > 300) or (bet < 10)
			m.user.notice "Place a bet between 10 to 300 please."
			return
		end

		if $DataBase['users'].find{ |h| h['nick'] == m.user.authname.downcase }
			if ($DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] < bet)
				m.user.notice "You don't have that kind of money"
			else
				# shuffle the deck twice
				deck = @deck.shuffle
				deck = deck.shuffle

				# deal the cards
				@hand[m.user.nick] = { "player" => [ @deck[0], @deck[2] ], "dealer" => [ @deck[1], @deck[3] ], "bet" => bet }

				deck.slice!(0..3)

				@hand[m.user.nick]["deck"] = deck

				# Take the money
				$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] -= bet
			end
			save_DB
			m.user.notice "Your hand: %s(%s). Dealer's hand: %s." % [ show_hand(@hand[m.user.nick]['player']), hand_count(@hand[m.user.nick]['player']), @hand[m.user.nick]['dealer'][0][1] ]
		end
	end


	match /hit/i, method: :blackjack_hit, :react_on => :channel
	def blackjack_hit (m)
		return if ignore_nick(m.user.nick) # ignore ignored users
		return if (@hand.key?(m.user.nick) == false) # ignore users who don't have a hand

		@hand[m.user.nick]["player"] << @hand[m.user.nick]["deck"][0]
		@hand[m.user.nick]["deck"].slice!(0)

		if hand_count(@hand[m.user.nick]["player"]) > 21
			m.reply "#{m.user.nick}: Better luck next time\u000F | Your hand: %s(%s)." % [ show_hand(@hand[m.user.nick]['player']), hand_count(@hand[m.user.nick]['player']) ]
			@hand.delete(m.user.nick)
		else
			m.user.notice "Your hand: %s(%s). Dealer's hand: %s." % [ show_hand(@hand[m.user.nick]['player']), hand_count(@hand[m.user.nick]['player']), @hand[m.user.nick]['dealer'][0][1] ]
		end
	end


	match /stay/i, method: :blackjack_stay, :react_on => :channel
	def blackjack_stay (m)
		return if ignore_nick(m.user.nick) # ignore ignored users
		return if (@hand.key?(m.user.nick) == false) # ignore users who don't have a hand

		q = 0

		dealer_hand = hand_count(@hand[m.user.nick]["dealer"])
		player_hand = hand_count(@hand[m.user.nick]["player"])

		# Dealer hits until they have 17+
		while (dealer_hand < 17)
			@hand[m.user.nick]["dealer"] << @hand[m.user.nick]["deck"][0]
			dealer_hand = hand_count(@hand[m.user.nick]["dealer"])
			@hand[m.user.nick]["deck"].slice!(0)
			q += 1
		end

		# Dealer Bust
		if dealer_hand > 21
			m.reply "#{m.user.nick}: Dealer bust\u000F | Your hand: %s(%s). Dealer's hand: %s(%s)." % [ show_hand(@hand[m.user.nick]['player']), hand_count(@hand[m.user.nick]['player']), show_hand(@hand[m.user.nick]['dealer']), hand_count(@hand[m.user.nick]['dealer']) ]
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += (@hand[m.user.nick]["bet"] * 2)
		
		# Tie
		elsif dealer_hand == player_hand
			m.reply "#{m.user.nick}: Draw\u000F | Your hand: %s(%s). Dealer's hand: %s(%s)." % [ show_hand(@hand[m.user.nick]['player']), hand_count(@hand[m.user.nick]['player']), show_hand(@hand[m.user.nick]['dealer']), hand_count(@hand[m.user.nick]['dealer']) ]
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += @hand[m.user.nick]["bet"]
		
		# Player wins
		elsif player_hand > dealer_hand
			m.reply "#{m.user.nick}: You win\u000F | Your hand: %s(%s). Dealer's hand: %s(%s)." % [ show_hand(@hand[m.user.nick]['player']), hand_count(@hand[m.user.nick]['player']), show_hand(@hand[m.user.nick]['dealer']), hand_count(@hand[m.user.nick]['dealer']) ]
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += (@hand[m.user.nick]["bet"] * 2)
			
		# Player loses
		else 
			m.reply "#{m.user.nick}: Better luck next time\u000F | Your hand: %s(%s). Dealer's hand: %s(%s)." % [ show_hand(@hand[m.user.nick]['player']), hand_count(@hand[m.user.nick]['player']), show_hand(@hand[m.user.nick]['dealer']), hand_count(@hand[m.user.nick]['dealer']) ]
		end

		@hand.delete(m.user.nick)
		save_DB
	end			


	match /surrender/i, method: :blackjack_surrender, :react_on => :channel
	def blackjack_surrender (m)
		return if ignore_nick(m.user.nick) # ignore ignored users
		return if (@hand.key?(m.user.nick) == false) # ignore users who don't have a hand

		m.user.notice "Better luck next time!"
		$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += (@hand[m.user.nick]["bet"] / 2)
		@hand.delete(m.user.nick)

		save_DB
	end


	match /hand/i, method: :blackjack_show_hand, :react_on => :channel
	def blackjack_show_hand (m)
		return if ignore_nick(m.user.nick) # ignore ignored users
		return if (@hand.key?(m.user.nick) == false) # ignore users who don't have a hand

		m.user.notice "Your hand: %s(%s). Dealer's hand: %s." % [ show_hand(@hand[m.user.nick]['player']), hand_count(@hand[m.user.nick]['player']), @hand[m.user.nick]['dealer'][0][1] ]
	end

end
