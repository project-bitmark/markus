# Description:
#   Bitmark Related Data
#
# Commands:
#   hubot network - show network details

module.exports = (robot) ->
  robot.respond /network$/i, (msg) ->
    robot.http("http://bitmark.co/statistics/data/livesummary.json")
      .get() (err, res, body) ->
        data = JSON.parse(body)
          msg.send "Block: <http://bitmark.co:3000/block/#{data.current.hash}|#{data.generated}> Difficulty: #{data.current.difficulty}"