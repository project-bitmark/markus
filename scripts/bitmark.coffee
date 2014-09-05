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
        hl = Math.round(json.data.hashrate_l/1000000) + " MH/s"
        hm = Math.round(json.data.hashrate_m/1000000) + " MH/s"
        hs = Math.round(json.data.hashrate_s/1000000) + " MH/s"
        change = (Math.ceil(json.generated/720)*720)-json.current
        net = "Block: http://bitmark.co:3000/block/#{json.data.current.hash}|#{json.generated} - "
        net += "Difficulty: #{json.data.current.difficulty} - "
        net += "Hashrate Averages: #{hl} #{hm} #{hs} - "
        net += "Change: #{change} blocks"
        msg.send net
