require 'set'

class CardsAgainstHumanity
	include Cinch::Plugin

	def reload_cards()
		$white_cards = File.open("white.txt").readlines().join.split("\n").shuffle
		$black_cards = File.open("black.txt").readlines().join.split("\n").shuffle
	end

	class Player
		attr_accessor :white_cards, :black_cards, :user, :picked_card, :selected
		attr_accessor :name
		attr_accessor :score
		attr_accessor :id
		

		def initialize(user)
			@user = user
			@name = user.nick
			@white_cards = []
			@black_cards = []
			@score = 0
			@id = 0
			@picked_card = false
			@selected = []
		end

		def print_player(pts=true, picked=false)
			name = @name
			points = "#{@score}"
			status = "#{@selected.size}/#{$game.black_card[:blanks]}"
			status = "CZAR" if $game.czar and @name == $game.czar.name

			"#{name}: #{points if pts}#{status if picked}"
		end

	end

	class CAHGame
		attr_accessor :game_state, :players, :czar, :creator, :round_in_progress,
			:black_card, :channel, :next_players, :card_map

		def initialize()
			@players = []
			@game_state = :nothing
			@czar = nil
			@creator = ""
			@round_in_progress = false
			@next_players = []
			@black_card = {:card => nil, :blanks => 0}
			@card_map = {}
			@m = nil
		end

		def start_round()
			@players += @next_players if @next_players.size > 0
			@next_players = []
			@round_in_progress = true

			old = @czar

			loop do
				@czar = @players.sample
				break if @czar != old
			end

			@czar.user.notice("Hey, you're the card czar for this round. Sit back and relax for a second while the others choose cards.")

			black = $black_cards.shift
			@black_card = { :card => black, :blanks => black.count("_") }


			@m.reply "Our Card Czar this round is #{@czar.name}. The black card is '#{@black_card[:card]}' (#{@black_card[:blanks]} blank(s))"

			deal_round()
		end

		def pick_card(m, nums)
			p = nil
			@players.each do |player|
				m.reply "You're the Card Czar" and return false if m.user.nick == @czar.name
				p = player and break if player.name == m.user.nick		
			end

			m.reply "You're not in the game, #{m.user.nick}! -join to join" and return if not p
			m.reply "You already picked" and return if p.picked_card 

				
			p.selected = nums
			p.picked_card = true

			m.reply "#{m.user.nick}, check"		

			@players.each do |player|
				return :round_on if not player.picked_card and player.name != @czar.name
			end

			:round_over
		end

		def add_player(m)
			@players.each do |p|
				return false if p.name == m.user.nick
			end

			@players << Player.new(m.user) if @game_state == :lobby
			@next_players << Player.new(m.user) if @game_state == :play
			true
		end

		def remove_player(m)
			p = nil
			@players.each do |player|
				if player.name == m.user.nick
					p = player
					break
				end 
			end

			m.reply "You are not currently in a game, #{m.user.nick}" and return if not p
			m.reply "#{p.name} has left the game"
			@players.delete(p)
		end

		def start_lobby(message)
			@game_state = :lobby
			@creator = message.user.nick
			@channel = message.channel
		end

		def start_game(m)
			@game_state = :play
			@m = m
		end

		def stop_game()
			@game_state = :nothing
			@players = []
			@czar = nil
			@creator = ""
		end

		def deal_round()
			@players.each do |player|
				next if player.name == @czar.user.nick
		
				player.selected = []
				player.picked_card = false

				while player.white_cards.size < 10 do
					reload_cards if $white_cards.empty?
					player.white_cards << $white_cards.shift
				end

				str = "Your hand: "

				i = 0
				player.white_cards.each do |c|
					i += 1
					str += "#{i}\u000F: #{c} | "
				end

				str += "When you're ready, send me '-pick <cardnumbers>' in #{@channel}"

				player.user.notice(str)
			end
		end

		def print_players(a=true, b=false)
			if @players.size == 0
				return "No one has joined the game yet"
			end

			@players.map {|player| player.print_player(a, b)}.join(", ")
		end

		def pick_winner(id)

			p = nil

			@players.each do |player|
				if not player.picked_card and player.name != @czar.name
					@m.reply "Some players still haven't played their cards"
					return
				end
			end

			@players.each do |player|
				next if player.name == @czar.name
				p = player if player.id == id	
			end

			@m.reply "I don't know who #{id} is supposed to be, but they're not here" and return if not p
			
			i = 0
			@black_card[:card].gsub!("_") {
				i += 1
				c = p.selected[i - 1] - 1
				p.white_cards[c]
			}

			@m.reply "We have a winner! #{p.name} said \"#{@black_card[:card]}\""
			p.score += 1

			@players.each do |player|
				remove = []
				player.selected.each {|x|
					remove << player.white_cards[x - 1]
				}

			player.white_cards -= remove

			end

			start_round
		end

		def send_choices()
			@m.reply("'#{@black_card[:card]}'")

			ids = (1..@players.size).to_a
			@players.shuffle

			@players.each do |player|
				next if player.name == @czar.name
				
				player.id = ids.shift

				cards = []

				player.selected.each { |x|
					cards << player.white_cards[x - 1]
				}
			
				i = 0
				s = @black_card[:card].gsub("_") {
					i += 1
					c = player.selected[i - 1] - 1
					player.white_cards[c]
				}

				@m.reply("#{player.id}: #{s}")
			end
		end
	end

	match /humanity/i, method: :create_game, :react_on => :channel
	def create_game(m)
		reload_cards()
		$game = CAHGame.new

		if $game.game_state == :nothing then
			$game.start_lobby m
			m.reply "Lobby started for #{$game.channel}, type -join to join the game, and -start to start the game"
		else
			m.reply "Game already in progress, -stop to stop it"
		end
	end

	match /end/i, method: :end_game, :react_on => :channel
	def end_game(m)
		if $game.game_state == :nothing then
			m.reply "No game in progress, -create to start one"
		else
			if m.user.nick == $game.creator then
				m.reply "The time for fun is over"
				$game.stop_game
			end
		end
	end

	match /join/i, method: :join_game, :react_on => :channel
	def join_game(m)
		if $game.game_state == :nothing then
			m.reply "No game in progress, -humanity to start one"
		end
		if $game.game_state != :nothing then
			if $game.add_player(m)
				m.reply "#{m.user.nick} has joined the game" +
					"#{" starting next round" if $game.game_state == :play}."
			end
		end
	end

	match /boot (\S+)/i, method: :boot_player, :react_on => :channel
	def boot_player(m, nick)
		if m.user.nick == $game.creator and m.user.nick != nick
			$game.players.delete_if { |p| p.name == nick }
			m.reply "#{name} has been removed from the game"
		end
	end

	match /pick (.*)/i, method: :pick, :react_on => :channel
	def pick(m, rest)
		m.reply "You can't do that right now, #{m.user.nick}" and return if $game.game_state != :play

		nums = rest.split(/\s/).map(&:to_i)

		nums.delete_if { |x| x > 10 or x < 1 }
		if nums.size != $game.black_card[:blanks]
			m.reply "You need to play #{$game.black_card[:blanks]} card(s) for this round" 
			return
		end

		set = nums.to_set
		m.reply "Can't play the same card twice" and return if set.size != nums.size

		status = $game.pick_card(m, nums)

		if status == :round_over then
			m.reply "Everyone's selections are in! #{$game.czar.name}, go ahead and pick a winner"
			$game.send_choices
		end
	end

	match /winner (\d+)/i, method: :winner, :react_on => :channel
	def winner(m, id)
		id = id.to_i

		return if $game.game_state != :play
		return if not $game.round_in_progress
		return if $game.czar.name != m.user.nick

		$game.pick_winner id
	end

	match /skip/i, method: :skip_round, :react_on => :channel
	def skip_round(m)
		if m.user.nick == $game.creator or m.user.nick == $game.czar.name
			m.reply "Round skipped"
			$game.start_round
		end
	end

	match /start/i, method: :start, :react_on => :channel
	def start(m)
		if $game.game_state != :lobby
			m.reply "Game should be in lobby to start"
		else
			if m.user.nick != $game.creator
				m.reply "Only #{$game.creator} can start the game"
			elsif $game.players.size < 3
				m.reply "You need to have at least 3 players to start the game"
			else
				m.reply "Game on! Current players are: #{$game.print_players}"
				$game.start_game(m)
				$game.start_round
			end
		end
	end

	match /card/i, method: :card, :react_on => :channel
	def card(m)
		m.reply "No game in progress right now" and return if $game.game_state != :play
		card = $game.black_card[:card]
	
		m.reply "'#{card}'"
	end

	match /players/i, method: :players, :react_on => :channel
	def players(m)
		if $game.game_state != :nothing
			m.reply "#{$game.print_players true, true}" if $game.game_state == :play
			m.reply "#{$game.print_players}" if $game.game_state == :lobby
		end
	end

	match /leave/i, method: :leave, :react_on => :channel
	def leave(m)
		$game.remove_player(m)
	end
end