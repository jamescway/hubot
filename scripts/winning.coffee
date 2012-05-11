# Winning
#
# winning - Display a Charlie Sheen winning picture
#

winning = [
  "http://userserve-ak.last.fm/serve/_/64924202/SH33N%2BCharlieSheenWinning.jpg",
  "http://media.tumblr.com/tumblr_lrfly1rFUF1qfzsvm.gif"
]

module.exports = (robot) ->
  robot.hear /.*(winning).*/i, (msg) ->
    msg.send msg.random winning
