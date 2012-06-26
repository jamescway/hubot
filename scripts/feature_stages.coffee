# Reports the SHA of the commit currently deployed to an environment.
#
# f<N> - Reports the SHA for that F environment.

feature_stage_url = (f) ->
  process.env.FEATURE_STAGE.replace(/#{name}/, f) + "/site/sha"

module.exports = (robot) ->
  robot.respond /f\d$/i, (msg) ->
    msg.http(feature_stage_url(msg))
      .get() (err, res, body) ->
        if err
          msg.send("Could not complete your request.")
        else
          msg.send(body)