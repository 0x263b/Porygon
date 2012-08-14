# encoding: utf-8

class UserSet
  include Cinch::Plugin


	# Last.fm username

	match /set lastfm (.+)/i, method: :set_lastfm
	def set_lastfm(m, username)
		return unless ignore_nick(m.user.nick).nil?
		begin
			old = LastfmDB.first(:nick => m.user.nick.downcase)
			old.destroy! unless old.nil?

			new = LastfmDB.new(
				:nick => m.user.nick.downcase,
				:username => username.downcase
			)
			new.save

			m.reply "last.fm user updated to: #{username}", true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 


	# Weather location

	match /set location (.+)/i, method: :set_location
	def set_location(m, areacode)
		return unless ignore_nick(m.user.nick).nil?
		begin
			old = LocationDB.first(:nick => m.user.nick.downcase)
			old.destroy! unless old.nil?

			new = LocationDB.new(
				:nick => m.user.nick.downcase,
				:location => areacode.downcase
			)
			new.save

			m.reply "location updated to: #{areacode}", true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 

end