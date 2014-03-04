# encoding: utf-8

class Quotes
	include Cinch::Plugin

	def initialize(*args)
		super
		@time = Hash.new Time.now.to_i
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

	match /quote (.+)$/i, method: :add_quote, :react_on => :channel
	def add_quote (m, quote)
		return if ignore_nick(m.user.nick) or check_time(m.user.nick)
		update_time(m.user.nick)

		Net::HTTP.post_form(URI.parse('http://rizon-qdb.herokuapp.com/quote'), {'quote[body]'=> quote, 'quote[channel]' => m.channel.to_s})

		m.reply "Quote added to database"
	rescue
		nil
	end

end