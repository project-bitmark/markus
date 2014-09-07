# Description:
#   Give and List User Points
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot give <number> points to <username> - award <number> points to <username>
#   hubot give <username> <number> points - award <number> points to <username>
#   hubot how many points does <username> have? - list how many points <username> has
#
# Author:
#   brettlangdon
#

points = {}

award_points = (msg, username, pts) ->
    points[username] ?= 0
    points[username] += parseInt(pts)
    msg.send pts + ' Awarded To ' + username

save = (robot) ->
    robot.brain.data.points = points

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        points = robot.brain.data.points or {}

    robot.hear /([\w\S]+)(\+\+)$/i, (msg) ->
        award_points(msg, 1, msg.match[1])
        save(robot)
 
    robot.hear /([\w\S]+)(\+\?)$/i, (msg) ->
        username = msg.match[1]
        points[username] ?= 0
        msg.send username + ' Has ' + points[username] + ' Points'
                
    robot.respond /give (\d+) points to (.*?)\s?$/i, (msg) ->
        award_points(msg, msg.match[2], msg.match[1])
        save(robot)

    robot.respond /give (.*?) (\d+) points/i, (msg) ->
        award_points(msg, msg.match[1], msg.match[2])
        save(robot)

    robot.respond /how many points does (.*?) have\??/i, (msg) ->
        username = msg.match[1]
        points[username] ?= 0
        msg.send username + ' Has ' + points[username] + ' Points'
       