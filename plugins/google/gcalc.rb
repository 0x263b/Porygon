# encoding: utf-8

class GCalc
	include Cinch::Plugin

	match /calc (.*)/iu

	def execute(m, query)
		return if ignore_nick(m.user.nick)

		jason = open("http://www.google.com/ig/calculator?hl=en&q=#{CGI.escape(query)}", "Referer" => "https://mcro.us/").read
		hashed = eval(jason).reduce({}) {|h,(k,v)| h[k.to_s] = v; h}
		
		if hashed["error"] == ""
			text = "%s => %s" % [hashed["lhs"], hashed["rhs"]]
		else
			text = "Could not compute"
		end

		m.reply "Calc 2| #{text}"
	end
end