# Description:
#   Bitmark Related Data
#
# Commands:
#   network|net - show network details
#   supply - show currency supply details
#   market(s) - show exchange details
#   address <address> - get btm address info

module.exports = (robot) ->
  robot.hear /^(network|net)$/i, (msg) ->
    robot.http("http://bitmark.co/statistics/data/livesummary.json")
      .get() (err, res, body) ->
        json = JSON.parse(body)
        hl = (json.data.hashrate_l/1000000000).toFixed(2) + ""
        hm = (json.data.hashrate_m/1000000000).toFixed(2) + ""
        hs = (json.data.hashrate_s/1000000000).toFixed(2) + ""
        change = (Math.ceil(json.generated/720)*720)-json.generated
        timesincelastretarget = json.data.current.time-json.data.lastchange.time
        avblocktime = (timesincelastretarget)/(720-change)
        performance = Math.floor((120/avblocktime)*10000)/100
        nextdiff = json.data.current.difficulty*(120/avblocktime)
        if nextdiff < json.data.current.difficulty
          nextdiff = Math.max(json.data.current.difficulty/4, nextdiff)
        if nextdiff > json.data.current.difficulty
          nextdiff = Math.min(json.data.current.difficulty*4, nextdiff)
        nextdiff = Math.floor(nextdiff)
        maxretargettime = 345600 # 4 days
        if (timesincelastretarget) >= 345600
          confidence = 100
        else
          confidence = Math.floor(((720-change)/720)*100)
        mintotarget = Math.ceil(change*2/(performance/100))
        hourtoretarget = (mintotarget/60).toFixed(2)
        timetoretarget =  "" + hourtoretarget + " hrs"
        timetoretarget =  "" + mintotarget + " mins" if change < 120
        target = (((json.data.current.difficulty*4294967296)/120)/1000000000).toFixed(2) + " GH/s"
        timesincelastretargethrs = (timesincelastretarget/3600).toFixed(2)
        elapsedretargettime = "" + timesincelastretargethrs + " hrs"
        elapsedretargettime =  "" + (timesincelastretargethrs*60) + " mins" if timesincelastretargethrs < 2
        net = "Block: http://bitmark.co:3000/block/#{json.data.current.hash}|#{json.generated},"
        net += "Target: #{target}, "
        net += "Hashrate: #{hl}, #{hm}, #{hs} GH/s"
        net += ", Performance: #{performance}%" if change < 660
        net += "\n"
        net += "Diff: #{json.data.current.difficulty}"
        net += ", next: ~#{nextdiff} (confidence #{confidence}%)" if change < 660
        net += " - Last Retarget: #{elapsedretargettime} ago, "
        net += "change in #{change} blocks (~#{timetoretarget}) "
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
        
  robot.hear /^(market|markets|polo)$/i, (msg) ->
    robot.http("https://poloniex.com/public?command=returnTicker")
      .get() (err, res, body) ->
        json = JSON.parse(body)
        btm = json.BTC_BTM
        pc = Math.round(btm.percentChange * 100, 2)
        price = "*POLO*: Last: #{btm.last} - "
        price += "Volume: #{btm.baseVolume} BTC / #{btm.quoteVolume} BTM - "
        vwa = (btm.baseVolume/btm.quoteVolume).toFixed(8)
        price += "VWAP: #{vwa}"
        spread = (btm.lowestAsk - btm.highestBid).toFixed(8)
        price += " - Spread: #{spread}\n"
        msg.send price
    robot.http("https://bittrex.com/api/v1.1/public/getmarketsummary?market=btc-btm")
      .get() (err, res, body) ->
        json = JSON.parse(body)
        btm = json.result[0]
        price = "*BITT*: Last: #{btm.Last} - "
        price += "Volume: #{btm.BaseVolume} BTC / #{btm.Volume} BTM - "
        vwa = (btm.BaseVolume/btm.Volume).toFixed(8)
        price += "VWAP: #{vwa}"
        spread = (btm.Ask - btm.Bid).toFixed(8)
        price += " - Spread: #{spread}\n"
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
      
