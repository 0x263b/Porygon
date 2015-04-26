# Porygon
---

### APIs in use

* [Bing Translate](https://datamarket.azure.com/account)
* [Lastfm](http://www.last.fm/api/accounts)
* [Wolfram Alpha](http://products.wolframalpha.com/api/)
* [Twitter](https://dev.twitter.com/apps)
* [Yahoo GeoPlanet](http://developer.yahoo.com/geo/geoplanet/)
* [Youtube](https://developers.google.com/youtube/v3/docs/search/list)

---

### Installation

Clone this repo and `bundle install` the dependencies. Edit [porygon.rb](https://github.com/killwhitey/Porygon/blob/master/porygon.rb#L24-L55) to include your account settings, API keys, and [server address](https://github.com/killwhitey/Porygon/blob/master/porygon.rb#L158).

To start the bot do `ruby daemon.rb start`

Once connected, it's time to add it to some channels. In a pm say something along the lines of

	<you> Bot: add admin you
	<you> Bot: join #myChannel

Now the bot, `Bot`, listens to `you` for restricted commands and will auto-join `#myChannel`.