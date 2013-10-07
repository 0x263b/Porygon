# encoding: utf-8

class UserSet
  include Cinch::Plugin


	# Last.fm username

	match /set lastfm (\S+)/i, method: :set_lastfm
	def set_lastfm(m, username)
		return if ignore_nick(m.user.nick)
		begin
			if $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }
				$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['lastfm'] = username.downcase
			else
				$DataBase['users'] << {"nick"=> m.user.nick.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> username.downcase, "location"=> nil, "karma"=> 0}
			end

			save_DB

			m.reply "last.fm user updated to: #{username}", true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 


	# Weather location

	match /set location (.+)/i, method: :set_location
	def set_location(m, areacode)
		return if ignore_nick(m.user.nick)
		begin
			if $DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }
				$DataBase['users'].find{ |h| h['nick'] == m.user.nick.downcase }['location'] = areacode.downcase
			else
				$DataBase['users'] << {"nick"=> m.user.nick.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> nil, "location"=> areacode.downcase, "karma"=> 0}
			end

			save_DB

			m.reply "location updated to: #{areacode}", true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 

end