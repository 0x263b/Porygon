# encoding: utf-8

# 
#  This does not currently work
#  Will fix later
#


#  https://github.com/halan/BotCabueta/blob/b26bf4bc6d41ca71b030a0ab00d760f4902cd4ec/cabueta.rb

module Config
  @@CONFIG_FILE = 'tweet.yml'

  def self.get
    YAML::load_file @@CONFIG_FILE
  end

  def self.put content
    File.open(@@CONFIG_FILE, 'w') do |f|
      f.write content
    end
  end
end

class TwitterClient
  attr_accessor :client

  def initialize config
    unless config['twitter'][:secret] and config['twitter'][:token]

      @client = TwitterOAuth::Client.new config['twitter']
      request_token = client.request_token
      puts "Authorize => #{request_token.authorize_url}"
      puts 'Verifier:'
      verifier = gets

      access_token = client.authorize request_token.token, request_token.secret, :oauth_verifier => verifier.strip
      unless client.authorized?
        puts 'Authorization failed'
        exit
      else
        Config.put (config['twitter'].merge( :token => access_token.token, :secret => access_token.secret)).to_yaml
      end
    else
      @client = TwitterOAuth::Client.new config['twitter']
    end

    exit unless @client.authorized?
  end
end

@@twitter = TwitterClient.new(Config::get).client

class Tweet
  include Cinch::Plugin
  attr_accessor :timeline, :last_id
  react_on :channel # Only tweet from inside a channel

  @@quietance = 80

  def load_timeline
    @timeline ||= []

    if @last_id
      @timeline = @@twitter.friends_timeline(:since_id => @last_id, :include_rts => true) + @timeline
    else
      @timeline = @@twitter.friends_timeline(:include_rts => true, :count => 1) + @timeline
    end
  end

  def last_tweet
    load_timeline if not @timeline or @timeline.empty?

    tweet = @timeline.last
    @last_id = tweet['id_str']
    @timeline.delete tweet

    return tweet
  rescue
    nil
  end

  $lastline = Hash.new(Time.now.to_i)
  #$currenttime = Time.now.to_i

  #match /tweet (.+)/, method: :tweet
  listen_to :channel
  #def tweet(m, message)
  def listen(m)
    return unless Time.now.to_i > $lastline[m.channel]
    return unless @@twitter.authorized? and ignore_nick(m.user.nick) == false # Ignore fags

    begin
      channel = m.channel.to_s

      charcount = m.user.nick.length + channel.length

      message = m.message
      message = message[0..136-charcount] if message.length > 136 - charcount # Trim the message if it's too long
      message = message.gsub(/\x1f|\x02|\x12|\x0f|\x16|\x03(?:\d{1,2}(?:,\d{1,2})?)?/, '') # Strip color codes, etc.
      message = message.gsub(/[\n\f\r\t\v]/, '') # Strip weird spaces

      tweettext = "#{m.user.nick}: #{message} #{channel}"

      @@twitter.update "#{tweettext}"
      #m.reply "0,1Twitter #{tweettext}"
      $lastline[m.channel] = Time.now.to_i + 120
    rescue Timeout::Error
      nil
    rescue
      nil
    end
  end
end