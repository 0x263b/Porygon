# encoding: utf-8

class BlackJack
	include Cinch::Plugin

	def initialize(*args)
		super
		@hand = Hash.new

		# our decks of cards
		@deck = [
			"A\u2665", "2\u2665", "3\u2665", "4\u2665", "5\u2665", "6\u2665", "7\u2665", "8\u2665", "9\u2665", "10\u2665", "J\u2665", "Q\u2665", "K\u2665", # Hearts
			"A\u2663", "2\u2663", "3\u2663", "4\u2663", "5\u2663", "6\u2663", "7\u2663", "8\u2663", "9\u2663", "10\u2663", "J\u2663", "Q\u2663", "K\u2663", # Clubs
			"A\u2660", "2\u2660", "3\u2660", "4\u2660", "5\u2660", "6\u2660", "7\u2660", "8\u2660", "9\u2660", "10\u2660", "J\u2660", "Q\u2660", "K\u2660", # Spades
			"A\u2666", "2\u2666", "3\u2666", "4\u2666", "5\u2666", "6\u2666", "7\u2666", "8\u2666", "9\u2666", "10\u2666", "J\u2666", "Q\u2666", "K\u2666"] # Diamonds
	end


	# Counts your points
	def hand_count(hand)
		aces = 0
		total = 0

		hand.each do |card|
			if card[0] =~ /^A/
				aces += 1
				total += 11
			elsif card[0] =~ /^[JQK]/
				total += 10
			elsif card[0] =~ /^\d+/
				total += card.gsub(/\\u\d+$/i, '').to_i
			end
		end

		# Drop aces to 1 if we bust
		while (total > 21) and (aces > 0)
			aces -= 1
			total -= 10
		end

		return total
	end


	# Start a game
	match /blackjack (\d+)/i, method: :blackjack_bet, :react_on => :channel
	def blackjack_bet (m, bet)
		return if ignore_nick(m.user.nick) # ignore ignored users
		m.user.refresh unless m.user.authed? # ignore unidentified users

		@hand.delete(m.user.nick)
		bet = bet.to_i

		if $DataBase['users'].find{ |h| h['nick'] == m.user.authname.downcase }
			if ($DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] < bet)
				m.user.notice "You don't have that kind of money"
			else
				# shuffle the deck
				@deck = @deck.shuffle

				# deal the cards
				@hand[m.user.nick] = { "player" => [ @deck[0], @deck[2] ], "dealer" => [ @deck[1], @deck[3] ], "bet" => bet }

				# Take the money
				$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] -= bet
			end
			save_DB
			m.user.notice "Your hand: %s (%s). Dealer's hand: %s." % [ @hand[m.user.nick]['player'], hand_count(@hand[m.user.nick]['player']), @hand[m.user.nick]['dealer'][0] ]
		end
	end


	match /hit/i, method: :blackjack_hit, :react_on => :channel
	def blackjack_hit (m)
		return if ignore_nick(m.user.nick) # ignore ignored users
		return if (@hand.key?(m.user.nick) == false) # ignore users who don't have a hand

		@deck = @deck.shuffle

		@hand[m.user.nick]["player"] << @deck[0]

		if hand_count(@hand[m.user.nick]["player"]) > 21
			m.user.notice "BUST! Your hand: %s (%s)." % [@hand[m.user.nick]['player'], hand_count(@hand[m.user.nick]['player'])]
			@hand.delete(m.user.nick)
		else
			m.user.notice "Your hand: %s (%s). Dealer's hand: %s." % [ @hand[m.user.nick]['player'], hand_count(@hand[m.user.nick]['player']), @hand[m.user.nick]['dealer'][0] ]
		end
	end


	match /stay/i, method: :blackjack_stay, :react_on => :channel
	def blackjack_stay (m)
		return if ignore_nick(m.user.nick) # ignore ignored users
		return if (@hand.key?(m.user.nick) == false)	# ignore users who don't have a hand

		q = 0
		@deck = @deck.shuffle

		dealer_hand = hand_count(@hand[m.user.nick]["dealer"])
		player_hand = hand_count(@hand[m.user.nick]["player"])

		while (dealer_hand < 17)
			@hand[m.user.nick]["dealer"] << @deck[q]
			dealer_hand = hand_count(@hand[m.user.nick]["dealer"])
			q += 1
		end

		if dealer_hand > 21
			m.user.notice "DEALER BUST! Your hand: %s (%s). Dealer's hand: %s (%s)." % [ @hand[m.user.nick]['player'], hand_count(@hand[m.user.nick]['player']), @hand[m.user.nick]['dealer'], hand_count(@hand[m.user.nick]['dealer'])]
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += (@hand[m.user.nick]["bet"] * 2)
			@hand.delete(m.user.nick)
		
		elsif dealer_hand == player_hand
			m.user.notice "TIE! Your hand: %s (%s). Dealer's hand: %s (%s)." % [ @hand[m.user.nick]['player'], hand_count(@hand[m.user.nick]['player']), @hand[m.user.nick]['dealer'], hand_count(@hand[m.user.nick]['dealer'])]
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += @hand[m.user.nick]["bet"]
			@hand.delete(m.user.nick)
		
		elsif player_hand > dealer_hand
			m.user.notice "YOU WIN! Your hand: %s (%s). Dealer's hand: %s (%s)." % [ @hand[m.user.nick]['player'], hand_count(@hand[m.user.nick]['player']), @hand[m.user.nick]['dealer'], hand_count(@hand[m.user.nick]['dealer'])]
			$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += (@hand[m.user.nick]["bet"] * 2)
			@hand.delete(m.user.nick)
		else 
			m.user.notice "DEALER WINS! Your hand: %s (%s). Dealer's hand: %s (%s)." % [ @hand[m.user.nick]['player'], hand_count(@hand[m.user.nick]['player']), @hand[m.user.nick]['dealer'], hand_count(@hand[m.user.nick]['dealer'])]
			@hand.delete(m.user.nick)
		end

		save_DB
	end			


	match /surrender/i, method: :blackjack_surrender, :react_on => :channel
	def blackjack_surrender (m)
		return if ignore_nick(m.user.nick) # ignore ignored users
		return if (@hand.key?(m.user.nick) == false)	# ignore users who don't have a hand

		m.user.notice "Better luck next time!"
		$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['botcoins'] += (@hand[m.user.nick]["bet"] / 2)
		@hand.delete(m.user.nick)

		save_DB
	end


	match /hand/i, method: :blackjack_show_hand, :react_on => :channel
	def blackjack_show_hand (m)
		return if ignore_nick(m.user.nick) # ignore ignored users
		return if (@hand.key?(m.user.nick) == false)	# ignore users who don't have a hand

		m.user.notice "Your hand: %s (%s). Dealer's hand: %s." % [ @hand[m.user.nick]['player'], hand_count(@hand[m.user.nick]['player']), @hand[m.user.nick]['dealer'][0] ]
	end

end
