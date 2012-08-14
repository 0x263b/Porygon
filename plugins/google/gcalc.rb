# encoding: utf-8

class GCalc
	include Cinch::Plugin

	match /calc (.*)/iu

	def execute(m, query)
		return unless ignore_nick(m.user.nick).nil?

		begin
			jason = open("http://www.google.com/ig/calculator?hl=en&q=#{CGI.escape(query)}", "Referer" => "https://undef.tv/").read
			hashed = eval(jason).reduce({}) {|h,(k,v)| h[k.to_s] = v; h}
			
			return unless hashed["lhs"].length > 0
			
			text = "%s => %s" % [hashed["lhs"], hashed["rhs"]]
		rescue
			text = "Could not compute."
		end

		m.reply "Calc 2| #{text}"
	end
end