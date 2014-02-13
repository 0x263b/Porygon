# Porygon
---

### APIs in use

* [Bing Translate](https://datamarket.azure.com/account)
* [Lastfm](http://www.last.fm/api/accounts)
* [Wolfram Alpha](http://products.wolframalpha.com/api/)
* [Twitter](https://dev.twitter.com/apps)
* [Yahoo GeoPlanet](http://developer.yahoo.com/geo/geoplanet/)

---
### Installation

Clone this repo and `bundle install` the dependencies. Edit [porygon.rb](https://github.com/killwhitey/Porygon/blob/master/porygon.rb#L24-L55) to include your account settings, API keys, and [server address](https://github.com/killwhitey/Porygon/blob/master/porygon.rb#L158).

Once you have the bot connected, it's time to add it to some channels. In a pm say something along the lines of

	<you> Bot: add admin you
	<you> Bot: join #myChannel
	
Now the bot listens to `you` for restricted commands and will auto-join `#myChannel`.