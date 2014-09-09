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
        hl = Math.round(json.data.hashrate_l/1000000) + ""
        hm = Math.round(json.data.hashrate_m/1000000) + ""
        hs = Math.round(json.data.hashrate_s/1000000) + ""
        change = (Math.ceil(json.generated/720)*720)-json.generated
        avblocktime = (json.data.current.time-json.data.lastchange.time)/(720-change)
        performance = Math.floor((120/avblocktime)*10000)/100
        nextdiff = Math.floor(json.data.current.difficulty*(120/avblocktime))
        confidence = Math.floor(((720-change)/720)*100)
        target = Math.floor(((json.data.current.difficulty*4294967296)/120)/1000000) + " MH/s"
        net = "Block: http://bitmark.co:3000/block/#{json.data.current.hash}|#{json.generated} - "
        net += "Diff: #{json.data.current.difficulty} - "
        net += "Target: #{target} - "
        net += "Hashrate: #{hl} #{hm} #{hs} MH/s - "
        net += "Change: #{change} - "
        net += "Performance: #{performance}% - " if change < 660
        net += "Next Diff: ~#{nextdiff} (confidence #{confidence}%)" if change < 660
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
        mul = Math.pow(10, 8)
        vwa = Math.round((btm.baseVolume/btm.quoteVolume)*mul)/mul
        price += "VWAP: #{vwa}"
        msg.send price
