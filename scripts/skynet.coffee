# Fires missiles at people.
#
# blitzkrieg <device> - Fires ALL THE MISSILES.
# fire <device> - Fires a missile from <device>.
# kill <person> - Fires a missle at <person>.
# reset <device> - Resets <device> to starting position.
# move <device> <direction> <value> - Moves the device in a certain direction.

redis = require("redis-url").connect(process.env.REDISTOGO_URL)

insanity = [
  "http://i290.photobucket.com/albums/ll247/Tijuana22/Nooooooo.jpg",
  "http://www.colinfahey.com/funny_images/haha_quaker_nuclear_launch_detected.jpg",
  "http://4.bp.blogspot.com/-VT9-iZgON1c/TgDA0YOspqI/AAAAAAAAHtI/PPmevY6T-K4/s1600/Nuclear%2BLaunch%2BDetected.png"
]

people =
  sam: 
    ["godzilla",
      [
        ["right", 3250],
        ["up", 540],
        ["fire", 4]
      ]
    ]

send = (device, instructions) ->
  message = JSON.stringify instructions
  redis.publish device, message

module.exports = (robot) ->
  robot.respond /reset (.+)/i, (msg) ->
    device = msg.match[1]
    command = ["zero", 0]

    send device, [command]

  robot.respond /move (.+) (up|down|right|left) (\d+)/i, (msg) ->
    device = msg.match[1]
    direction = msg.match[2]
    value = parseInt(msg.match[3], 10)

    command = [direction, value]

    send device, [command]

  robot.respond /blitzkrieg (.+)/i, (msg) ->
    device = msg.match[1]
    command = ["fire", 4]

    if device == "all"
      msg.send msg.random insanity

    send device, [command]

  robot.respond /fire (.+)/i, (msg) ->
    device = msg.match[1]
    command = ["fire", 1]

    send device, [command]

  robot.respond /kill (.+)/i, (msg) ->
    person = msg.match[1]

    if target = people[person]
      send target[0], target[1]