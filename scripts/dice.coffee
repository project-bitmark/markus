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
    points[username] = (parseFloat(points[username]) + parseFloat(marks)).toFixed(5)
    
del_marks = (username, marks) ->
    points[username] = (parseFloat(points[username]) - parseFloat(marks)).toFixed(5)
    
save = (robot) ->
    robot.brain.data.points = points
    robot.brain.data.nhouse = house

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        points = robot.brain.data.points or points
        house = robot.brain.data.nhouse or house

    robot.hear /^dice ([\d]+) ([\d.]+)$/i, (msg) ->
        if msg.message.user.room != "casino"
          msg.send "#{msg.message.user.name}: please use me in #casino"
          return
        bet = parseInt(msg.match[1])
        if bet >= 64000
          msg.send "#{msg.message.user.name}: dice must be less than 64000"
          return
        if bet <= 100
          msg.send "#{msg.message.user.name}: dice must be higher than 100"
          return
        amount = parseFloat(msg.match[2])
        if amount < 1
          msg.send "#{msg.message.user.name}: amount must be 1₥ or higher than "
          return
        if amount > 500000
          msg.send "#{msg.message.user.name}: amount must be 500,000₥ or lower"
          return
        odds = (bet/max).toFixed(4)
        mul = ((max/bet)*0.981).toFixed(4)
        win = (amount*mul).toFixed(5)
        maxwin = (house/4).toFixed(5)
        maxamount = maxwin/mul
        if amount > maxamount
          msg.send "#{msg.message.user.name}: maximum for this bet is #{maxamount}₥"
          return
        if amount > points[msg.message.user.name]
          msg.send "#{msg.message.user.name}: you tried to bet #{amount}₥ but only have #{points[msg.message.user.name]}₥"
          return
        dice = Math.floor(Math.random() * max) + 1
        del_marks(msg.message.user.name, amount)
        house += amount
        if bet < dice
          save(robot)
          msg.send "Sorry #{msg.message.user.name}, dice: #{dice}, amount: #{amount}, bet: #{bet}, odds: #{odds}, multiplier: #{mul}, *lost*"
          return
        add_marks(msg.message.user.name, win)
        house -= win
        msg.send "Congratulations #{msg.message.user.name}! dice: #{dice}, amount: #{amount}, bet: #{bet}, odds: #{odds}, multiplier: #{mul}, *win*: #{win}₥"
        save(robot)

    robot.hear /^dice ([\d]+) max$/i, (msg) ->
        if msg.message.user.room != "casino"
          msg.send "#{msg.message.user.name}: please use me in #casino"
          return
        bet = parseInt(msg.match[1])
        if bet >= 64000
          msg.send "#{msg.message.user.name}: dice must be less than 64000"
          return
        if bet <= 100
          msg.send "#{msg.message.user.name}: dice must be higher than 100"
          return
        odds = (bet/max).toFixed(4)
        mul = ((max/bet)*0.981).toFixed(4)
        maxwin = (house/4).toFixed(5)
        maxamount = maxwin/mul
        amount = Math.min( points[msg.message.user.name], 500000, maxamount )
        if amount < 1
          msg.send "#{msg.message.user.name}: amount must be 1₥ or higher"
          return
        win = (amount*mul).toFixed(5)
        dice = Math.floor(Math.random() * max) + 1
        del_marks(msg.message.user.name, amount)
        house += amount
        if bet < dice
          save(robot)
          msg.send "Sorry #{msg.message.user.name}, dice: #{dice}, amount: #{amount}, bet: #{bet}, odds: #{odds}, multiplier: #{mul}, *lost*"
          return
        add_marks(msg.message.user.name, win)
        house -= win
        msg.send "Congratulations #{msg.message.user.name}! dice: #{dice}, amount: #{amount}, bet: #{bet}, odds: #{odds}, multiplier: #{mul}, *win*: #{win}₥"
        save(robot)
                
    robot.hear /^dice float$/i, (msg) ->
        msg.send "Dice float is: #{house}₥"
