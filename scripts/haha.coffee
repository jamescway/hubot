# HaHa

nelson = ["http://www.youtube.com/watch?v=rX7wtNOkuHo"]

module.respond = (robot) ->
	robot.hear /.*(haha).*/i, (msg) ->
		msg.send nelson