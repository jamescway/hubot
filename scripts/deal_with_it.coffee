# Deal With It
#
# deal with it - Display a deal with it gif

gifs = [
  "http://gifs.gifbin.com/032011/1300124817_deal-with-it-irl.gif",
  "http://gifs.gifbin.com/072010/1280482491_dealwithit-the-long-version.gif",
  "http://gifs.gifbin.com/082010/1281004519_smoking-crab-deal-with-it.gif",
  "http://assets0.ordienetworks.com/images/GifGuide/DealWithIt/tumblr_lgd1hgYbNt1qzq72w.gif",
  "http://assets0.ordienetworks.com/images/GifGuide/DealWithIt/tumblr_lh6sayYpIJ1qzaxefo1_400.gif",
  "http://assets0.ordienetworks.com/images/GifGuide/DealWithIt/tumblr_limthcd5BD1qfyv11o1_500.gif",
  "http://assets0.ordienetworks.com/images/GifGuide/DealWithIt/dealwithitneti.gif",
  "http://assets0.ordienetworks.com/images/GifGuide/DealWithIt/startrekwithit.gif",
  "http://i226.photobucket.com/albums/dd314/NiGHTS8888/slothshades-1.gif",
  "https://lh5.googleusercontent.com/-A_PpLwYXjqY/Tl7L3cW1hvI/AAAAAAAAAdo/Z4rN2ReL9pg/s288/deal-with-it-pokemon.gif"
]

module.exports = (robot) ->
  robot.hear /.*(deal with it).*/i, (msg) ->
    msg.send msg.random gifs
