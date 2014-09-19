# Description:
#   Bitmark Related Data
#
# Commands:
#   network|net - show network details
#   supply - show currency supply details
#   poloniex|polo - show poloniex exchange details
#   address <address> - get btm address info

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
        nextdiff = json.data.current.difficulty*(120/avblocktime)
        if nextdiff < json.data.current.difficulty
          nextdiff = Math.max(json.data.current.difficulty/4, nextdiff)
        if nextdiff > json.data.current.difficulty
          nextdiff = Math.min(json.data.current.difficulty*4, nextdiff)
        nextdiff = Math.floor(nextdiff)
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
        
  robot.hear /^(address) b([\w\S]+)$/i, (msg) ->
    checkAddress msg, "b#{msg.match[2]}"

  robot.hear /^(address) foundation$/i, (msg) ->
    checkAddress msg, "bQmnzVS5M4bBdZqBTuHrjnzxHS6oSUz6cG"
  
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
        pc = Math.round(btm.percentChange * 100, 2)
        price = "*POLO*: Last: #{btm.last} - "
        price += "Volume: #{btm.baseVolume} BTC / #{btm.quoteVolume} BTM - "
        vwa = (btm.baseVolume/btm.quoteVolume).toFixed(8)
        price += "VWAP: #{vwa}\n"
    robot.http("https://bittrex.com/api/v1.1/public/getmarketsummary?market=btc-btm")
      .get() (err, res, body) ->
        json = JSON.parse(body)
        btm = json.result[0]
        pc = Math.round(btm.percentChange * 100, 2)
        price += "*BITT*: Last: #{btm.Last} - "
        price += "Volume: #{btm.BaseVolume} BTC / #{btm.Volume} BTM - "
        vwa = (btm.BaseVolume/btm.Volume).toFixed(8)
        price += "VWAP: #{vwa}\n"
        msg.send price
        msg.send price

checkAddress = (msg, address) ->
  msg.http("http://bitmark.co:3000/api/addr/#{address}")
    .get() (err, res, body) ->
      json = JSON.parse(body)
      bal = "Balance: #{json.balance}, "
      bal += "unconfirmed: #{json.unconfirmedBalance}, "
      bal += "in: #{json.totalReceived}, "
      bal += "out: #{json.totalSent}, "
      bal += "http://bitmark.co:3000/address/#{json.addrStr}|explorer"
      msg.send bal