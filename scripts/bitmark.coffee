# Description:
#   Bitmark Related Data
#
# Commands:
#   hubot network - show network details

module.exports = (robot) ->
  robot.respond /network/i, (msg) ->
    robot.http("http://bitmark.co/statistics/data/livesummary.json")
      .get() (err, res, body) ->
        json = JSON.parse(body)
        hl = Math.round(json.data.hashrate_l/1000000) + "MH/s"
        net = "Block: http://bitmark.co:3000/block/#{json.data.current.hash}|#{json.generated} "
        net += "Difficulty: #{json.data.current.difficulty} "
        net += "Hashrate Averages: #{hl} "
        msg.send net
