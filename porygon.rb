# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

require 'rubygems'

require 'cinch'

# Database stuff
require 'dm-core'
require 'dm-migrations'
require 'dm-sqlite-adapter'


# Web stuff
require 'mechanize'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'openssl'
require 'json'

require 'date'
require 'time'
require 'cgi'

# Encoding issues
require 'iconv'

# Bitly API interfacing
require 'bitly'


# Global vars
$BOTNICK       = ""
$BOTPASSWORD   = ""
$BOTOWNER      = "" # Make sure this is lowercase
$BOTURL        = "http://developers.im/help"
$BOTGIT        = "https://github.com/ibkshash/Porygon"

# API Keys
#$BINGAPI       = "" Fuck bing, man

$AZUREU        = "" # For translate.rb
$AZUREP        = ""

$BITLYUSER 	   = "" # For everything basically
$BITLYAPI 	   = ""

$LASTFMAPI 	   = ""

$WOLFRAMAPI    = ""

$YAHOO         = "" # For weather

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


# Ignore list
def ignore_nick(user)
	check = IgnoreDB.first(:nick => user.downcase)
	check.nil? ? (return nil) : (return true)
end

# Passive on/off
def disable_passive(channel)
	check = PassiveDB.first(:channel => channel.downcase)
	check.nil? ? (return nil) : (return true)
end

# Passive on/off
def disable_passive_files(channel)
	check = PassiveFDB.first(:channel => channel.downcase)
	check.nil? ? (return nil) : (return true)
end

# Bot admins
def check_admin(user)
	user.refresh
	@admins = AdminDB.first(:nick => user.authname.downcase)
end


# Internal
require_relative './plugins/internal/basic.rb'
require_relative './plugins/internal/admin.rb'    # Admin
require_relative './plugins/internal/userset.rb'  # UserSet


# Advacned plugins
require_relative './plugins/8ball/8ball.rb'                       # Eightball
require_relative './plugins/bing.rb'                              # Bing
require_relative './plugins/google/google.rb'                     # Google
require_relative './plugins/lastfm/lastfm.rb'                     # Lastfm
require_relative './plugins/google/gcalc.rb'                      # GCalc
require_relative './plugins/random/rand.rb'                       # Pick
require_relative './plugins/translate/translate.rb'               # Translate
require_relative './plugins/tvrage/tvrage.rb'                     # Tvrage
require_relative './plugins/twitter/twitter.rb'                   # Twitter
require_relative './plugins/urbandictionary/urbandictionary.rb'   # UrbanDictionary
require_relative './plugins/uri/uri.rb'                           # Uri
require_relative './plugins/weather/weather.rb'                   # Weather
require_relative './plugins/wolfram/wolfram.rb'                   # Wolfram
require_relative './plugins/youtube/youtube.rb'                   # Youtube


bot = Cinch::Bot.new do
	configure do |c|
		c.plugins.prefix    = /^:/
		c.server            = "irc.pantsuland.net"
		c.port              = 6697
		c.ssl.use           = true
		c.ssl.verify        = false
		c.nick              = $BOTNICK
		c.realname          = $BOTNICK
		c.user              = $BOTNICK
		c.channels          = []
		c.plugins.plugins   = [
			Basic, 
			Admin, 
			UserSet, 
			UrbanDictionary, 
			Weather, 
			Lastfm, 
			Uri, 
			Translate, 
			Twitter, 
			Eightball, 
			Pick, 
			Youtube, 
			Google, 
			Wolfram,
			Tvrage,
			GCalc
		]
	end
end

bot.start
