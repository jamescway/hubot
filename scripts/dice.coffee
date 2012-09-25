dice = [ 
	"raise",
	"shun",
	"churn"
]

// dice2 = [ "barn",
// 					"outsider",
// 					"butter"
// ]

module.exports = (robot) ->
  robot.hear /.*(roll).*/i, (msg) ->
    msg.send msg.random dice