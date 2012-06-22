# YARLY
# Proper reply to "ORLY?"

yarly = [
	"http://members.optusnet.com.au/mollypig/yarly.JPG"
]

module.exports = (robot) ->
  robot.hear /.*(yarly).*/i, (msg) ->
    msg.send msg.random yarly