#!/usr/bin/env ruby
# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

require 'rubygems'
require 'cinch'

# Web stuff
require 'mechanize'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'openssl'
require 'json'
require 'oauth'
require 'date'
require 'time'
require 'cgi'
require "ruby-duration"
require 'timeout'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# Global vars
$BOTNICK       = ""
$BOTPASSWORD   = ""
$BOTOWNER      = "" # Make sure this is lowercase
$BOTURL        = "http://waa.ai/porygon"
$BOTGIT        = "https://github.com/killwhitey/Porygon"

# API Keys

# Bing Translate API
# https://datamarket.azure.com/account
$AZUREU        = "" # Customer ID
$AZUREP        = "" # Primary Account Key

# Lastfm API
# http://www.last.fm/api/accounts
$LASTFMAPI 	   = ""

# Wolfram Aplha API
# http://products.wolframalpha.com/api/
$WOLFRAMAPI    = ""

# Twitter API (to get full tweet info)
# https://dev.twitter.com/apps
$TWITTER_CONSUMER_KEY        = ""
$TWITTER_CONSUMER_SECRET     = ""
$TWITTER_ACCESS_TOKEN        = ""
$TWITTER_ACCESS_TOKEN_SECRET = ""

# Yahoo! GeoPlanet API
# http://developer.yahoo.com/geo/geoplanet/
$YAHOO_GEO = ""

# Youtube API
# https://developers.google.com/youtube/v3/docs/search/list
$YOUTUBE_API = ""


$DBFILE = "database.json"

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


# Ignore list
def ignore_nick(user)
	if $DataBase['users'].find{ |h| h['nick'] == user.downcase } && $DataBase['users'].find{ |h| h['nick'] == user.downcase }['ignored'] == true
		puts 'ignored'
		return true
	else
		puts 'not ignored'
		return false
	end
end

# Passive on/off
def uri_disabled(channel)
	if $DataBase['channels'].find{ |h| h['channel'] == channel.downcase } && $DataBase['channels'].find{ |h| h['channel'] == channel.downcase }['passive'] == false
		return true
	else
		return false
	end
end

# Passive on/off
def file_info_disabled(channel)
	if $DataBase['channels'].find{ |h| h['channel'] == channel.downcase } && $DataBase['channels'].find{ |h| h['channel'] == channel.downcase }['file_info'] == false
		return true
	else
		return false
	end
end

# Bot admins
def check_admin(user)
	user.refresh
	if $DataBase['users'].find{ |h| h['nick'] == user.authname.downcase } && $DataBase['users'].find{ |h| h['nick'] == user.authname.downcase }['admin'] == true
		return true
	else
		return false
	end
end


# URL shortener
# Note: short URLs expire after 14 days
def shorten_url(long)
	begin
		complete_results = Timeout.timeout(3) do
			url = URI.parse('http://mnn.im/s')
			http = Net::HTTP.new(url.host, url.port)
			response, body = http.post(url.path, long)
			parsed = JSON.parse(response.body)
			return parsed["url"]["short_url"]
		end
	rescue Timeout::Error
		url = URI.parse("https://api.waa.ai/shorten?url=#{long}")
		response = Net::HTTP.get(url)
		parsed = JSON.parse(response)
		return parsed["data"]["url"]
	end
end


# Internal
require_relative'./plugins/internal/basic.rb'
require_relative'./plugins/internal/admin.rb'    # Admin
require_relative'./plugins/internal/userset.rb'  # UserSet


# Advanced plugins
require_relative'./plugins/8ball/8ball.rb'                       # Eightball
require_relative'./plugins/google/google.rb'                     # Google
require_relative'./plugins/lastfm/lastfm.rb'                     # Lastfm
require_relative'./plugins/random/rand.rb'                       # Pick
require_relative'./plugins/translate/translate.rb'               # Translate
require_relative'./plugins/tvrage/tvrage.rb'                     # Tvrage
require_relative'./plugins/twitter/twitter.rb'                   # Twitter
require_relative'./plugins/urbandictionary/urbandictionary.rb'   # UrbanDictionary
require_relative'./plugins/uri/uri.rb'                           # Uri
require_relative'./plugins/weather/weather.rb'                   # Weather
require_relative'./plugins/wolfram/wolfram.rb'                   # Wolfram
require_relative'./plugins/youtube/youtube.rb'                   # Youtube
require_relative'./plugins/botcoins/botcoins.rb'                 # BotCoins
require_relative'./plugins/botcoins/blackjack.rb'                # BlackJack
require_relative'./plugins/horoscopes/horoscope.rb'              # Horoscope
require_relative'./plugins/quote/quotes.rb'                      # Quotes


bot = Cinch::Bot.new do
	configure do |c|
		c.plugins.prefix    = /^:/ # Replace : with the prefix you want
		c.server            = "irc.rizon.net"
		c.port              = 6697
		c.ssl.use           = true
		c.ssl.verify        = false
		c.nick              = $BOTNICK
		c.realname          = $BOTNICK
		c.user              = $BOTNICK
		c.modes             = ["GRp"]
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
			BotCoins,
			BlackJack,
			Horoscope,
			Quotes
		]
	end
end

bot.start
