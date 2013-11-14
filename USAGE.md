# Porygon
---
### Functions
* [Google](#google)
* [Google Calculator](#google-calculator)
* [WolframAlpha](#wolframalpha)
* [Youtube](#youtube)
* [Lastfm](#lastfm)
* [Weather](#weather)
* [Translate](#translate)
* [Twitter](#twitter)
* [Urban Dictionary](#urban-dictionary)
* [TVRage](#tvrage)
* [Random](#random)
* [8ball](#8ball)
* [Horoscope](#horoscope)
* [Botcoins](#botcoins)
* [URL Parser](#url-parser)
* [Admin functions](#admin-functions)

***

### Google
Gets the first result from Google for *search query*

**-g/-google** *search query*

	-google Richard Stallman
	Google | Richard Stallman's Personal Page | http://stallman.org/
	Google | Richard Stallman - Wikipedia, the free encyclopedia | http://en.wikipedia.org/wiki/Richard_Stallman
	Google | More results http://mcro.us/ukioc | Images: http://mcro.us/u7w1r


### Google Calculator
Calculates *equation* in Google Calculator

**-calc** *equation*

	-calc 50 kg in lbs
	Calc | 50 kilograms => 110.231131 pounds
	

### WolframAlpha
Finds the answer of *question* using WolfarmAlpha

**-wa** *question*

	-wa time in Bosnia
	Wolfram | current time in Bosnia and Herzegovina => 8:41:47 pm CEST | Monday, October 7, 2013 | More info: http://mcro.us/ui6e7


### Youtube
Gets the first result from Youtube for *search query* 

**-yt/-youtube** *search query*

	-yt Richard Stallman interject
	YouTube | I'd just like to interject... | 03:00 | 37,079 views | 269/5 | http://youtu.be/QlD9UBTcSW4 | More results: http://mcro.us/ubrov


### Last.fm
Associates your current irc nick with *user*.
Other lastfm functions will default to this nick if no user is provided.

**-set lastfm** *user*
	
	<jewface> -set lastfm jewy
	<Porygon> jewface: last.fm user updated to: jewy
 

User info and overall charts for *user*

**-lastfm** *user*

	-lastfm Cbbleh
	Last.fm | Cbbleh (23/m/-) | 23,758 Scrobbles | Overall Top Artists: Coroner (838), Destruction (776), Queen (681), Robert de Visée (664), Johann Sebastian Bach (573)
	

Artist info (top tracks, tags, etc.) for *artist*

**-artist** *artist*

	-artist 4minute
	Last.fm 4minute (4,120,188 plays; 49,295 listeners). Top tracks: Huh, I My Me Mine, Hot Issue. Tagged as: k-pop, korean, female vocalists. URL: http://www.last.fm/music/4minute


Upcoming events for *artist*

**-events** *artist*

	-events The Field
	Upcoming events for The Field | Bristol: 12 Oct 13, Lisboa: 19 Oct 13, Paris: 01 Nov 13


Weekly stats for *user*

**-charts** *user*

	-charts Cbbleh
	Last.fm | Top 5 Weekly artists for Cbbleh | Slayer (26), Iced Earth (25), Jean-Féry Rebel (23), Morbid Saint (15), Judas Priest (14)


Compares two users the returns the tasteometer rating and common artists

**-compare** *user user*

	-compare Cbbleh cocaine
	Last.fm | cbbleh vs xzwqt | 43.8% | Common artists include: Johann Sebastian Bach, Franz Joseph Haydn, Wolfgang Amadeus Mozart, Domenico Scarlatti, Franz Schubert


Returns the currently playing/last scrobbled track for *user* and top artist tags

**-np** *user*
	
	-np Cbbleh
	Last.fm | cbbleh is playing: "Super X-9" by Daikaiju from Daikaiju | Surf, surf rock, instrumental, instrumental surf rock
	

### Weather
Google Weather for *location*

**-w/-we/-weather** *location*

	-weather Washington, DC
	Weather | Washington, DC | Mostly Cloudy 44°F. Humidity: 49%. Wind: 12 km/h | Mon: Partly Cloudy 49°F/33°F | Tue: Partly Cloudy 49°F/40°F
	
Associates your current irc nick with *location*.
Other weather functions will default to this location if none is provided.

**-set location** *location* 

	<jewface> -set location Washington, DC
	<Porygon> jewface: location updated to: Washington, DC


### Translate
Translates *text* using bing translate

**-tr/-translate** *from to text*

	-translate en fr pig disgusting
	Translate | en=>fr | "porc écoeurant"

| code | Language           | code | Language           | code | Language |
| ---: | :------------------- | ---: | :------------------- | ---:| :--------- |
| ar  | Arabic 			| ht  | Haitian			| ro  | Romanian | 
| cs  | Czech 			| hu  | Hungarian			| es  | Spanish| 
| da  | Danish 			| id  | Indonesian			| ru  | Russian| 
| de  | German 			| it  | Italian 			| sk  | Slovak | 
| en  | English			| ja  | Japanese 			| sl  | Slovene| 
| et  | Estonian 			| ko  | Korean			| sv  | Swedish| 
| fi  | Finnish			| lt  | Lithuanian			| th  | Thai| 
| fr  | French			| lv  | Latvian 			| tr  | Turkish| 
| nl  | Dutch				| no  | Norwegian 			| uk  | Ukrainian| 
| el  | Greek 			| pl  | Polish			| vi  | Vietnamese | 
| he  | Hebrew 			| pt  | Portuguese
| zh-CHS | Chinese Simplified	| zh-CHT  | Chinese Traditional |  | | 


### Twitter
Gets the latest tweet for *username*
 
**-tw/-twitter** *username*
 
	-tw TheOnion
	Twitter | The Onion (@TheOnion) | "Look at them—huffing and puffing around the Capitol building. You can’t be angry when your heart’s melting." http://onion.com/19uWTqJ | Posted 9 minutes ago


### Urban Dictionary
Gets the first definition of *query* at UrbanDictionary.com

**-u/-ur/-urban** *query*

	-urban 4chan
	UrbanDictionary 4chan: you have just entered the very heart, soul, and life force of the internet. this is a place beyond sanity, wild and untamed. there is nothing new here. "new" content on 4chan is not found; it is created from old material. every interesting, offensive, shoc…


Gets the *n*th definition for *query* (only works for definitions 1-7)

**-u/-ur/-urban** *n* *query*

	-urban 3 4chan
	UrbanDictionary | 4chan | 4chan.org is the absolute hell hole of the internet, but still amusing. Entering this website requires you leave your humanity behind before entering. WARNING: You will see things on /b/ that you wish you had never seen in your life.
	

### TVRage
Looks up *show* info on TVRage

**-tv** *show*

	-tv Legend of Korra
	TVRage | The Legend of Korra (Animation | Anime | Action | Adventure | Fantasy) Nickelodeon 2012 Status: Returning Series Next Ep: 02x06 The Sting Oct/11/2013 Friday at 07:00 pm


### Random
Randomly picks an option from an array separated by |

**-r/-rand** *one | two | three*

	-r do work | don't do work
	don't do work
	

### 8Ball
Gives and 8ball style answer to a *question*

**-8ball** *question*

	-8ball Am I going to score with this one girl I just finished talking to?
	My sources say no
	

### Horoscope
Checks the horoscope for *user*. Checks your horoscope if no *user* provided.

**-horoscope** *user*

	<jewface> -horoscope
	<Porygon> jewface: Remember: Nobody is perfect. Whatever you lack in talent and ability, you more than make up for in well-timed excuses.
	

### Botcoins
Mines cyberspace for virtual currency

**-mine**

	-mine
	You have mined 3 botcoin(s), giving you a total of 14
	
Loots *user*'s virtual bank account

**-loot** *user*

	-loot jewface
	You stole 4 botcoins from jewface!
	
Checks the account balance for *user*. Checks your balance if no *user* provided.

**-balance** *user*

	<jewface> -balance
	<Porygon> jewface has mined 14 botcoins 
	
Gives *user* *n* botcoins from your stash

**-give** *user* *n*

	-give Cbbleh 5
	Transfered 5 botcoins to Cbbleh

Sets the channel topic in exchange for 50 botcoins

**-topic** *message*

	-topic I'm rich, b"tch!
	* Porygon sets the topic to "I'm rich, b"tch"

Kicks *user* in exchange for 100 botcoins

**-kick** *user*

	-kick Cbbleh
	* Chanserv has kicked Cbbleh

Bans *user* in exchange for 300 botcoins

**-ban** *user*

	-ban Cbbleh
	* Chanserv sets mode +b Cbbleh*!*@*
	* Chanserv has kicked Cbbleh


### URL Parser
Returns the title of a page and the host for html URLs.
Returns the type, size, and (sometimes) filename of a file URL.

	https://news.ycombinator.com/
	Title | Hacker News | news.ycombinator.com

	http://ompldr.org/vNmhrdA
	File "omg.png" image/png; charset=binary 126.9 KB (ompldr.org)


---
### Admin functions
These functions use the bot's nick as their prefix. The examples assume the nick is *Porygon*

Change the bot's nick

**Porygon:** *nick*
	
	Porygon: nick Magneton
	* Porygon changes nick to Magneton	

Quit

**Porygon:** **quit** *message*

	Porygon: quit bye bye
	* Porygon has quit (bye bye)
	
Message a user

**Porygon:** **msg** *user* *your message*

	Porygon: msg Cbbleh you are mum
	<Porygon> you are mum
	
Say something in a channel

**Porygon:** **say** *#channel* *your message*

	Porygon: say #DEVELOPERS hello!
	<Porygon> hello!
	
Kick a user

**Porygon:** **kick** *user* *reason*

	Porygon: kick Cbbleh >being this white
	* Porygon has kicked Cbbleh from the channel (>being this white)
	
Ban a user

**Porygon:** **ban** *user* *reason*

	Porygon: ban Cbbleh get out already
	* Porygon sets mode +b Cbbleh*!*@*
	* Porygon has kicked Cbbleh (get out already)
	
Ignore a user

**Porygon:** **ignore** *nick*

	Porygon: ignore Cbbleh
	<Porygon> I never liked him anyway
	
Unignore a user

**Porygon:** **unignore** *nick*

	Porygon: unignore Cbbleh
	<Porygon> Sorry about that
	
Pastes a list of ignored users to [mcro.us](http://mcro.us)

**Porygon:** **list ignores**

	Porygon: list ignores

Adds a user to the admin list

**Porygon:** **add admin** *user*

	Porygon: add admin cocaine
	<Porygon> A new master!
	
Removes a user from the admin list

**Porygon:** **remove admin** *user*

	Porygon: remove admin cocaine
	<Porygon> I never liked him anyway
	
Pastes a list of bot admins to [mcro.us](http://mcro.us)

**Porygon:** **list admins**

	Porygon: list admins
	
Enables the URL parser for the channel

**Porygon:** **passive on** *channel*

	Porygon: passive on
	<Porygon> Now reacting to URIs
	
Disables the URL parser for the channel

**Porygon:** **passive off** *channel*

	Porygon: passive off
	<Porygon> No longer reacting to URIs
	
Enables showing info for file URLs in a channel

**Porygon:** **file info on** *channel*

	Porygon: file info on
	<Porygon> Now reacting to file URIs
	
Disables showing info for file URLs in a channel

**Porygon:** **file info off** *channel*

	Porygon: file info off
	<Porygon> No longer reacting to file URIs
	
Joins a channel and adds it to auto join

**Porygon:** **join** *channel*

	Porygon: join #foobar
	* Porygon has joined #foobar
	
Parts a channel and removes it from auto join

**Porygon:** **part** *channel*

	Porygon: part
	* Porygon has left the channel
	
Pastes a list of the channels to [mcro.us](http://mcro.us)

**Porygon:** **list channels**

	Porygon: list channels
	
Removes a user's last.fm from the database

**Porygon:** **remove lastfm** *user*

	Porygon: remove lastfm Cbbleh
	<Porygon> Done
	
Removes a user's location from the database

**Porygon:** **remove location** *user*

	Porygon: remove location Cbbleh
	<Porygon> Done