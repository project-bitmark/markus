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
    points[username] += parseFloat(pts)
    msg.send pts + '₥ to ' + username

save = (robot) ->
    robot.brain.data.points = points

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        points = robot.brain.data.points or {}

    robot.hear /@?([\w\S]+)(\+\+)$/i, (msg) ->
        award_points(msg, msg.match[1], 1)
        save(robot)
 
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
    	nms = msg.match[1];
    	nms = nms.replace(/[@:]/g, '');
    	nms = nms.split(/[, ]+/)
        award_points(msg, nm, msg.match[2]) for nm in nms
        save(robot)
       