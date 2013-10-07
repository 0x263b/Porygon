# encoding: utf-8

class Pick
	include Cinch::Plugin

	match /r(?:and)? (.+)/i
	def execute(m, query)
		return if ignore_nick(m.user.nick)

		begin
			options = query.split(/\|/)
			m.reply options[rand(options.length)], true
		rescue
			nil
		end
	end
end