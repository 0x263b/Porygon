# Database stuff
require 'dm-core'
require 'dm-migrations'
require 'dm-sqlite-adapter'
require 'json'


DBFILE = ""
DataMapper.setup(:default, "sqlite3://" + DBFILE)


class LastfmDB 
	include DataMapper::Resource
	property(:id, Serial)
	property(:nick, String, :unique => true)
	property(:username, String)
end 

class IgnoreDB
	include DataMapper::Resource
	property(:id, Serial)
	property(:nick, String, :unique => true)
end 

class LocationDB 
	include DataMapper::Resource
	property(:id, Serial)
	property(:nick, String, :unique => true)
	property(:location, String)
end 

class PassiveDB
	include DataMapper::Resource
	property(:id, Serial)
	property(:channel, String, :unique => true)
end 

class PassiveFDB
	include DataMapper::Resource
	property(:id, Serial)
	property(:channel, String, :unique => true)
end 

class JoinDB
	include DataMapper::Resource
	property(:id, Serial)
	property(:channel, String, :unique => true)
end 

class AdminDB
	include DataMapper::Resource
	property(:id, Serial)
	property(:nick, String, :unique => true)
end 


DataMapper.finalize

if(!File.exists?(DBFILE))
	DataMapper.auto_migrate!
elsif(File.exists?(DBFILE))
	DataMapper.auto_upgrade!
end

# =========================



$DBFILE = "./database.json"

if File.exist? $DBFILE
	File.open($DBFILE, "r") do |f|
		$DataBase = JSON.parse(f.read)
		$DataBase.default = 0
	end
	puts 'opened database'
else
	puts 'making file'
	$DataBase = Hash.new(0)
end

def save_DB
	File.open($DBFILE, "w") do |f|
		f.write($DataBase.to_json)
	end
	puts 'saved database'
end




# Update users

IgnoreDB.all.each do |item|
	if $DataBase['users'].find{ |h| h['nick'] == item.nick.downcase }
		$DataBase['users'].find{ |h| h['nick'] == item.nick.downcase }['ignored'] = true
	else
		$DataBase['users'] << {"nick"=> item.nick.downcase, "admin"=> false, "ignored"=> true, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
	end
end

LastfmDB.all.each do |item|
	if $DataBase['users'].find{ |h| h['nick'] == item.nick.downcase }
		$DataBase['users'].find{ |h| h['nick'] == item.nick.downcase }['lastfm'] = item.username
	else
		$DataBase['users'] << {"nick"=> item.nick.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> item.username, "location"=> nil, "botcoins"=> 0}
	end
end

LocationDB.all.each do |item|
	if $DataBase['users'].find{ |h| h['nick'] == item.nick.downcase }
		$DataBase['users'].find{ |h| h['nick'] == item.nick.downcase }['location'] = item.location
	else
		$DataBase['users'] << {"nick"=> item.nick.downcase, "admin"=> false, "ignored"=> false, "lastfm"=> nil, "location"=> item.location, "botcoins"=> 0}
	end
end

AdminDB.all.each do |item|
	if $DataBase['users'].find{ |h| h['nick'] == item.nick.downcase }
		$DataBase['users'].find{ |h| h['nick'] == item.nick.downcase }['admin'] = true
	else
		$DataBase['users'] << {"nick"=> item.nick.downcase, "admin"=> true, "ignored"=> false, "lastfm"=> nil, "location"=> nil, "botcoins"=> 0}
	end
end


# Update channels

JoinDB.all.each do |item|
	if $DataBase['channels'].find{ |h| h['channel'] == item.channel.downcase }
		$DataBase['channels'].find{ |h| h['channel'] == item.channel.downcase }['auto_join'] = true
	else
		$DataBase['channels'] << {"channel"=> item.channel.downcase, "auto_join"=> true, "passive"=> true, "file_info"=> true}
	end
end

PassiveDB.all.each do |item|
	if $DataBase['channels'].find{ |h| h['channel'] == item.channel.downcase }
		$DataBase['channels'].find{ |h| h['channel'] == item.channel.downcase }['passive'] = false
	else
		$DataBase['channels'] << {"channel"=> item.channel.downcase, "auto_join"=> false, "passive"=> false, "file_info"=> false}
	end
end

PassiveFDB.all.each do |item|
	if $DataBase['channels'].find{ |h| h['channel'] == item.channel.downcase }
		$DataBase['channels'].find{ |h| h['channel'] == item.channel.downcase }['file_info'] = false
	else
		$DataBase['channels'] << {"channel"=> item.channel.downcase, "auto_join"=> false, "passive"=> true, "file_info"=> false}
	end
end


save_DB

