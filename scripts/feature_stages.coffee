# Reports the SHA of the commit currently deployed to an environment.
#
# f<N> - Reports the SHA for that F environment.

module.exports = (robot) ->
  robot.respond /(f\d)$/i, (msg) ->
    url = process.env.HUBOT_FEATURE_STAGE.replace(/#{name}/, msg.match[1]) + "/site/sha"
    msg.send(url)
    # msg.http()
    #   .get() (err, res, body) ->
    #     if err
    #       msg.send("Could not complete your request.")
    #     else
    #       msg.send(body)