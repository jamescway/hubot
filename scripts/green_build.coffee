# Green build
#
# Hear 'green build' - Display a kermit!

kermits = [
  "http://images4.wikia.nocookie.net/__cb20101015155605/muppet/images/f/f3/Kermit4.jpg",
  "http://userserve-ak.last.fm/serve/_/42047967/Kermit+der+Frosch+kermit.jpg",
  "http://cdn.thegloss.com/files/2011/10/kermit-the-frog.jpg",
  "http://userserve-ak.last.fm/serve/252/2689486.jpg",
  "http://www.gadgetell.com/images/2007/05/kermit.jpg",
  "http://www.pastortimclark.com/wp-content/uploads/2011/11/kermit.jpg",
  "http://images.wikia.com/muppet/images/archive/7/79/20100202033216!Kermit-the-frog.jpg",
  "http://www.latimes.com/includes/projects/hollywood/portraits/kermit_the_frog.jpg",
  "http://imagecache2.allposters.com/images/pic/PYREU/PP30865-EU~Kermit-Boxes-Posters.jpg"
]

module.exports = (robot) ->
  robot.hear /.*(green build).*/i, (msg) ->
    msg.send msg.random kermits
