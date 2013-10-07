# encoding: utf-8

class Horoscope
	include Cinch::Plugin

	match /horoscope(?: (.+))?/i

	def execute(m, person)
		return if ignore_nick(m.user.nick)
		person ||= m.user.nick

		begin
			lines = %x{wc -l < "list.txt"}.to_i
			f = File.open('list.txt')
			a = f.readlines

			m.reply "%s: %s" % [person, a[rand(lines)]]
		rescue
			nil
		end
	end

end