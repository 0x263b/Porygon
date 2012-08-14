class Karma
  include Cinch::Plugin
  react_on :channel

  def initialize(*args)
    super
    @scores_file = "karma.json"
    if File.exist? @scores_file
      File.open(@scores_file, "r") do |f|
        @users = JSON.parse(f.read)
        @users.default = 0
      end
    else
      @users = Hash.new(0)
    end

    @time = Hash.new Time.now.to_i
  end

  match /sage (\S+)/i, method: :increment
  def increment(m, nick)
    return unless ignore_nick(m.user.nick).nil?

    return unless check_time(m.user.nick) == true
    update_time(m.user.nick)

    if nick == @bot.nick
      update_user(m.user.nick)
      show_score(m, m.user.nick)
    elsif nick == m.user.nick
      update_user(m.user.nick)
      show_score(m, m.user.nick)
    else
      update_user(nick)
      show_score(m, nick)
    end
  end

  match /fagstatus(?: (.+))?/i, method: :show_scores
  def show_scores(m, nick)
    return unless ignore_nick(m.user.nick).nil?

    nick ||= m.user.nick
    show_score(m, nick)
  end
  
  def update_time(nick)
    @time[nick.downcase] = (Time.now.to_i + 30)
  end

  def check_time(nick)
    nick = nick.downcase

    if @time.key?(nick) == true
      Time.now.to_i > @time[nick] ? (return true) : (return false)
    else
      update_time(nick)
      return true
    end
  end

  def show_score(m, nick)
    nick = nick.downcase

    case @users[nick]
    when 0..2    then comment = "What a bro."
    when 3..10   then comment = "This guy's getting on my nerves..."
    when 11..20  then comment = "Kick this guy already."
    when 21..80  then comment = "Someone ban this guy."
    when 81..999 then comment = "Request gline immediately."
    end

    m.reply "#{ nick } has been 12saged #{ @users[nick] } times. #{comment}"
  end

  def update_user(nick)
    @users[nick.downcase] += 1
    save
  end

  def save
    File.open(@scores_file, "w") do |f|
      f.write(@users.to_json)
    end
  end
end
