# encoding: utf-8

class Pick
	include Cinch::Plugin

	match /r(?:and)? (.+)/i
	def execute(m, query)
		return unless ignore_nick(m.user.nick).nil?

		begin
			options = query.split(/\|/)
			m.reply options[rand(options.length)], true
		rescue
			nil
		end
	end
end