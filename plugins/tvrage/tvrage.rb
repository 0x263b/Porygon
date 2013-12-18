# encoding: utf-8

class Tvrage
	include Cinch::Plugin

	match /tv (.+)/

	def execute(m, query)
		return if ignore_nick(m.user.nick)

		@retry = 2
		begin
			return unless @retry > 0
			url = open("http://services.tvrage.com/tools/quickinfo.php?show=#{CGI.escape(query)}").read
			linesArray=[] 
			url.each_line {|line| linesArray.push line.gsub(/[\r\n]/, "") }

			showName  = linesArray.grep(/^Show Name@/).to_s.gsub("Show Name@", '').gsub(/[\[\]\"]/, "")
			return unless showName.length > 1
			premiered = linesArray.grep(/^Premiered@/).to_s.gsub("Premiered@", "").gsub(/[\[\]\"]/, "")
			started   = linesArray.grep(/^Started@/).to_s.gsub("Started@", " Started: ").gsub(/[\[\]\"]/, "")
			ended     = linesArray.grep(/^Ended@/).to_s.gsub("Ended@", " Ended: ").gsub(/[\[\]\"]/, "")
			latest    = linesArray.grep(/^Latest Episode@/).to_s.gsub("Latest Episode@", " Latest Ep: ").gsub(/[\[\]\"]/, "").gsub("^", " ")
			nextep    = linesArray.grep(/^Next Episode@/).to_s.gsub("Next Episode@", " Next Ep: ").gsub(/[\[\]\"]/, "").gsub("^", " ")
			classif   = linesArray.grep(/^Classification@/).to_s.gsub("Classification@", "").gsub(/[\[\]\"]/, "").gsub("^", " ")
			status    = linesArray.grep(/^Status@/).to_s.gsub("Status@", " Status: ").gsub(/[\[\]\"]/, "").gsub("^", " ")
			genre     = linesArray.grep(/^Genres@/).to_s.gsub("Genres@", "").gsub(/[\[\]\"]/, "")
			network   = linesArray.grep(/^Network@/).to_s.gsub("Network@", "").gsub(/[\[\]\"]/, "")
			airs      = linesArray.grep(/^Airtime@/).to_s.gsub("Airtime@", " ").gsub(/[\[\]\"]/, "")

			airs = "" if nextep.length < 1

			m.reply "TVRage 07| #{showName} (#{classif} | #{genre}) #{network} #{premiered}#{status}#{nextep}#{airs}"
		rescue Timeout::Error
			@retry = @retry-1
			retry
		rescue
			nil
		end
	end
end