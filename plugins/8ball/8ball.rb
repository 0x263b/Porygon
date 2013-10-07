# encoding: utf-8

class Eightball
	include Cinch::Plugin

	match /8ball (.+)$/i
	def execute (m, s)
		return if ignore_nick(m.user.nick)

		eightball = [
			"It is certain",
			"It is decidedly so",
			"Without a doubt",
			"Yes - definitely",
			"You may rely on it",
			"As I see it, yes",
			"Most likely",
			"Outlook good",
			"Signs point to yes",
			"Yes",
			"Reply hazy, try again",
			"Ask again later",
			"Better not tell you now",
			"Cannot predict now",
			"Concentrate and ask again",
			"Don't count on it",
			"My reply is no",
			"My sources say no",
			"Outlook not so good",
			"Very doubtful",
			"Don't care, go away" # Don't tell anyone, but this 8ball is actually a 9ball!
		]

		begin
			m.reply eightball[rand(eightball.length)], true
		rescue
			nil
		end
	end

end
