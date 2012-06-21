# YARLY
# Proper reply to "ORLY?"

yarly = [
	"http://files.myopera.com/Sk8r644/albums/510337/Ya%20Rly.jpg"
]

module.exports = (robot) ->
  robot.hear /.*(yarly).*/i, (msg) ->
    msg.send yarly