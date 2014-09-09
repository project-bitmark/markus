# Description:
#   Bitmark Related Data
#
# Commands:
#   network|net - show network details
#   supply - show currency supply details
#   poloniex|polo - show poloniex exchange details

module.exports = (robot) ->
  robot.hear /^(network|net)$/i, (msg) ->
    robot.http("http://bitmark.co/statistics/data/livesummary.json")
      .get() (err, res, body) ->
        json = JSON.parse(body)
        hl = Math.round(json.data.hashrate_l/1000000) + " MH/s"
        hm = Math.round(json.data.hashrate_m/1000000) + " MH/s"
        hs = Math.round(json.data.hashrate_s/1000000) + " MH/s"
        change = (Math.ceil(json.generated/720)*720)-json.generated
        avblocktime = (json.data.current.time-json.data.lastchange.time)/(720-change)
        performance = Math.floor((avblocktime/120)*10000)/100
        nextdiff = Math.floor(json.data.current.difficulty*(avblocktime/120))
        confidence = Math.floor((720/change)*100)
        target = Math.floor(((json.data.current.difficulty*4294967296)/120)/1000000) + " MH/s"
        net = "Block: http://bitmark.co:3000/block/#{json.data.current.hash}|#{json.generated} - "
        net += "Difficulty: #{json.data.current.difficulty} - "
        net += "Target Hashrate: #{target} - "
        net += "Hashrate Averages: #{hl} #{hm} #{hs} - "
        net += "Change: #{change} - "
        net += "Performance: #{performance}% - "
        net += "Next Diff: ~#{nextdiff} (confidence #{confidence}%)"
        msg.send net

  robot.hear /^(supply)$/i, (msg) ->
    robot.http("http://bitmark.co/statistics/data/livesummary.json")
      .get() (err, res, body) ->
        json = JSON.parse(body)
        should = Math.floor((json.data.current.time-1405274442)/120)
        sbtm = should*20
        rbtm = json.generated*20
        diff = sbtm-rbtm 
        net = "BTM Supply: #{rbtm} BTM, and we had planned: #{sbtm} BTM - "
        net += "there is #{diff} less BTM in the world"
        msg.send net
        
  robot.hear /^(poloniex|polo)$/i, (msg) ->
    robot.http("https://poloniex.com/public?command=returnTicker")
      .get() (err, res, body) ->
        json = JSON.parse(body)
        btm = json.BTC_BTM
        price = "Last: #{btm.last} - "
        price += "Change: #{btm.percentChange}% - "
        price += "Volume: #{btm.baseVolume} BTC / #{btm.quoteVolume} BTM"
        msg.send price
