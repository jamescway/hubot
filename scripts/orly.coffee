# ORLY
# 1/5 of the images are en espanol

orly = [
	"http://api.ning.com/files/Xn6RV5Y50pbFK-4nfM7GdDho7NF3Lm7FDmT9YQonKh4_/orly.jpg",
	"http://anongallery.org/img/3/5/o-rly-orly-owl.jpg",
	"http://anongallery.org/img/3/5/o-rly-orly-owl.jpg",
	"http://anongallery.org/img/3/5/o-rly-orly-owl.jpg",
	"http://anongallery.org/img/3/5/o-rly-orly-owl.jpg"
]

module.exports = (robot) ->	
  robot.hear /.*(ORLY).*/i, (msg) ->
    msg.send msg.random orly