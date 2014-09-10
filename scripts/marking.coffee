# Description:
#   Give and List User Marks
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   mark <username> <number> - award <number> marks to <username>
#   username++ - give 1 mark to username
#   username+? - how many marks does <username> have?
#
# Author:
#   bitmark team
#

points = {}

award_points = (msg, username, pts) ->
    points[username] ?= 0
    points[username] = (parseFloat(points[username]) + parseFloat(pts)).toFixed(5)
    msg.send pts + '₥ to ' + username

save = (robot) ->
    robot.brain.data.points = points

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        points = robot.brain.data.points or {}

    robot.hear /@?([\w\S]+)(\+\+)$/i, (msg) ->
        award_points(msg, msg.match[1], 1)
        save(robot)
 
     robot.hear /resetme$/i, (msg) ->
        username = msg.message.user.name
        points[msg.message.user.name] = 1000
        msg.send msg.message.user.name + ' reset to ' + points[msg.message.user.name] + '₥'
               
    robot.hear /(\+\?)$/i, (msg) ->
        username = msg.message.user.name
        points[msg.message.user.name] ?= 0
        msg.send msg.message.user.name + ' has ' + points[msg.message.user.name] + '₥'
 
    robot.hear /@?([\w\S]+): (\+\+)$/i, (msg) ->
        award_points(msg, msg.match[1], 1)
        save(robot)
        
    robot.hear /@?([\w\S]+)(\+\?)$/i, (msg) ->
        username = msg.match[1]
        points[username] ?= 0
        msg.send username + ' has ' + points[username] + '₥'
 
     robot.hear /@?([\w\S]+): (\+\?)$/i, (msg) ->
        username = msg.match[1]
        points[username] ?= 0
        msg.send username + ' has ' + points[username] + '₥'
                       
    robot.hear /mark (.*) ([\d.]+)$/i, (msg) ->
        nms = msg.match[1].replace(/[@:]/g, '').split(/[, ]+/)
        award_points msg, nm, msg.match[2] for nm in nms
        save(robot)
        
       