# Integrates with memegenerator.net
#
# Y U NO <text>              - Generates the Y U NO GUY with the bottom caption
#                              of <text>
#
# I don't always <something> but when i do <text> - Generates The Most Interesting man in the World
#
# <text> (SUCCESS|NAILED IT) - Generates success kid with the top caption of <text>
#
# <text> ALL the <things>    - Generates ALL THE THINGS
#
# <text> TOO DAMN <high> - Generates THE RENT IS TOO DAMN HIGH guy
#
# Good news everyone! <news> - Generates Professor Farnsworth
#
# khanify <text> - TEEEEEEEEEEEEEEEEEXT!
#
# Not sure if <text> or <text> - Generates Futurama Fry
#
# Yo dawg <text> so <text> - Generates Yo Dawg
#
# If <text>, <text>? - Generates Philosoraptor
#
# scumbag <text>, <text> - Generates Scumbag Steve
#
# one does not simply <text> - Generates One Does Not Simply ...
#
# yoda <text>, <text> - Generates Yoda
#
# <text> you can't explain that - Generates Bill O'Reilly
#
# some say <text> all we know he's called the stig - Generates the Stig
#
# there's no <text> in <text> - Generates there's no crying in baseball meme
#
# <test>, you're going to/gonna have a bad time - Generates bad time ski instructor
#
# imagine a world <text> - Generates Spongebob meme

module.exports = (robot) ->
  robot.respond /(.*) (Y U NO .+)/i, (msg) ->
    memeGenerator msg, 2, 166088, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(I DON'?T ALWAYS .*) (BUT WHEN I DO,? .*)/i, (msg) ->
    memeGenerator msg, 74, 2485, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(.*)(SUCCESS|NAILED IT.*)/i, (msg) ->
    memeGenerator msg, 121, 1031, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(.*) (ALL the .*)/i, (msg) ->
    memeGenerator msg, 6013, 1121885, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(.*) (\w+\sTOO DAMN .*)/i, (msg) ->
    memeGenerator msg, 998, 203665, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(GOOD NEWS EVERYONE[,.!]?) (.*)/i, (msg) ->
    memeGenerator msg, 1591, 112464, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /khanify (.*)/i, (msg) ->
    memeGenerator msg, 6443, 1123022, "", khanify(msg.match[1]), (url) ->
      msg.send url

  robot.respond /(NOT SURE IF .*) (OR .*)/i, (msg) ->
    memeGenerator msg, 305, 84688, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(YO DAWG .*) (SO .*)/i, (msg) ->
	  memeGenerator msg, 79, 108785, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(IF .*), (.*\?)/i, (msg) ->
	  memeGenerator msg, 17, 984, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /scumbag (.*), (.*)/i, (msg) ->
	  memeGenerator msg, 142, 366130, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(one does not simply) (.*)/i, (msg) ->
	  memeGenerator msg, 689854, 3291562, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /yoda (.*), (.*)/i, (msg) ->
	  memeGenerator msg, 629, 963, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(.*) (you can't explain that)/i, (msg) ->
	  memeGenerator msg, 9623, 439720, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(some say .*) (all we know he's called the stig)/i, (msg) ->
    memeGenerator msg, 11480, 1121, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /((there's|theres) no (.+)) (in (.+))/i, (msg) ->
    memeGenerator msg, 1099784, 4728478, msg.match[1], msg.match[4], (url) ->
      msg.send url

  robot.respond /(brace (yourself|yourselves))(""|,) (.*)/i, (msg) ->
    memeGenerator msg, 121854, 1611300, msg.match[1], msg.match[4], (url) ->
      msg.send url

  robot.respond /(.*), (you're (going to|gonna) have a bad time)/i, (msg) ->
    memeGenerator msg, 825296, 3786537, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /(imagine a world).? (.*)/i, (msg) ->
    memeGenerator msg, 9603, 39519, msg.match[1], msg.match[2], (url) ->
      msg.send url
 
memeGenerator = (msg, generatorID, imageID, text0, text1, callback) ->
  username = process.env.HUBOT_MEMEGEN_USERNAME
  password = process.env.HUBOT_MEMEGEN_PASSWORD
  preferredDimensions = process.env.HUBOT_MEMEGEN_DIMENSIONS

  unless username? and password?
    msg.send "MemeGenerator account isn't setup. Sign up at http://memegenerator.net"
    msg.send "Then ensure the HUBOT_MEMEGEN_USERNAME and HUBOT_MEMEGEN_PASSWORD environment variables are set"
    return

  msg.http('http://version1.api.memegenerator.net/Instance_Create')
    .query
      username: username,
      password: password,
      languageCode: 'en',
      generatorID: generatorID,
      imageID: imageID,
      text0: text0,
      text1: text1
    .get() (err, res, body) ->
      result = JSON.parse(body)['result']
      if result? and result['instanceUrl']? and result['instanceImageUrl']? and result['instanceID']?
        instanceID = result['instanceID']
        instanceURL = result['instanceUrl']
        img = result['instanceImageUrl']
        msg.http(instanceURL).get() (err, res, body) ->
          # Need to hit instanceURL so that image gets generated
          if preferredDimensions?
            callback "http://images.memegenerator.net/instances/#{preferredDimensions}/#{instanceID}.jpg"
          else
            callback "http://images.memegenerator.net/instances/#{instanceID}.jpg"
      else
        msg.reply "Sorry, I couldn't generate that image."

khanify = (msg) ->
  msg = msg.toUpperCase()
  vowels = [ 'A', 'E', 'I', 'O', 'U' ]
  index = -1
  for v in vowels when msg.lastIndexOf(v) > index
    index = msg.lastIndexOf(v)
  "#{msg.slice 0, index}#{Array(10).join msg.charAt(index)}#{msg.slice index}!!!!!"
