# Fires missiles at people.
#
# fire <device> - Fires ALL THE MISSLES.
# kill <person> - Fires a missle at <person>.
# move <device> <direction> <value> - Moves the device in a certain direction.

redis = require("redis-url").connect(process.env.REDISTOGO_URL)

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
  robot.respond /move (.+) (up|down|right|left) (\d+)/i, (msg) ->
    device = msg.match[1]
    direction = msg.match[2]
    value = parseInt(msg.match[3], 10)

    command = [direction, value]

    send device, [command]

  robot.respond /fire (.+)/i, (msg) ->
    device = msg.match[1]
    command = ["fire", 1]

    send device, [command]

  robot.respond /kill (.+)/i, (msg) ->
    person = msg.match[1]

    if target = people[person]
      send target[0], target[1]