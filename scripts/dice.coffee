# Description:
#   reputation dice
#
# Commands:
#   dice <bet> <amount> - bet to roll lower than any number between 100 and 64000, with amount
#   dice float - get dice float

max = 65536
house = 1000000
points = {}

add_marks = (username, marks) ->
    points[username] ?= 0
    points[username] = parseFloat(points[username]) + parseFloat(marks)
    
del_marks = (username, marks) ->
    points[username] = parseFloat(points[username]) - parseFloat(marks)
    
save = (robot) ->
    robot.brain.data.points = points
    robot.brain.data.house = house

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        points = robot.brain.data.points or points
        house = robot.brain.data.house or house

    robot.hear /^dice ([\d]+) ([\d.]+)$/i, (msg) ->
        if msg.message.user.room != "casino"
          msg.send "please use me in #casino"
          return
        bet = parseInt(msg.match[1])
        if bet >= 64000
          msg.send "dice must be less than 64000"
          return
        if bet < 100
          msg.send "dice must be higher than 100"
          return
        amount = parseFloat(msg.match[2])
        if amount < 1
          msg.send "bet must be higher than 1₥"
          return
        if amount > 500
          msg.send "bet must be lower than 500₥"
          return
        if amount > points[msg.message.user.name]
          msg.send "you tried to bet #{amount}₥ but only have #{points[msg.message.user.name]}₥"
          return
        dice = Math.floor(Math.random() * max) + 1
        del_marks(msg.message.user.name, amount)
        if bet < dice
          house += amount
          save(robot)
          msg.send "Sorry, dice was #{dice} and you bet lower than #{bet}"
          return
        odds = (bet/max).toFixed(4)
        mul = ((max/bet)*0.981).toFixed(4)
        win = (amount*mul).toFixed(8)
        add_marks(msg.message.user.name, win)
        house -= win
        msg.send "Congratulations #{msg.message.user.name}! dice: #{dice}, bet: #{bet}, odds: #{odds}, multiplier: #{mul}, *win*: #{win}₥"
        save(robot)
        
    robot.hear /^dice float$/i, (msg) ->
        msg.send "Dice float is: #{house}₥"
