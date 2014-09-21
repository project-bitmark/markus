# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot ping - Reply with pong
#   hubot echo <text> - Reply back with <text>
#   hubot time - Reply with current time
#   hubot die - End hubot process
#   hubot datastructure - Show debug of datastructure msg.message

module.exports = (robot) ->
  robot.respond /PING$/i, (msg) ->
    msg.send "PONG"

  robot.respond /ADAPTER$/i, (msg) ->
    msg.send robot.adapterName

  robot.respond /ECHO (.*)$/i, (msg) ->
    msg.send msg.match[1]

  robot.respond /TIME$/i, (msg) ->
    msg.send "Server time is: #{new Date()}"

  robot.respond /DIE$/i, (msg) ->
    msg.send "LOL, you die."
    
  robot.hear /^pad$/i, (msg) ->
    msg.send "http://piratepad.nl/ep/pad/create?padId=bitmark|newpad"
    
  robot.hear /^datastructure$/i, (msg) ->
    msg.send JSON.stringify(msg.message)

