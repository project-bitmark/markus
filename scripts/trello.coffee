# Description:
#   Create new cards in Trello
#
# Dependencies:
#   "node-trello": "latest"
#
# Configuration:
#   HUBOT_TRELLO_KEY - Trello application key
#   HUBOT_TRELLO_TOKEN - Trello API token
#
# Commands:
#   hubot card <list> <name> - Create a new Trello card list can be (new|main|side|channel)
#   hubot show <list> - Show cards on list (new|main|side|channel)
#
# Notes:
#   To get your key, go to: https://trello.com/1/appKey/generate
#   To get your token, go to: https://trello.com/1/authorize?key=<<your key>>&name=Hubot+Trello&expiration=never&response_type=token&scope=read,write
#   Figure out what board you want to use, grab it's id from the url (https://trello.com/board/<<board name>>/<<board id>>)
#   To get your list ID, go to: https://trello.com/1/boards/<<board id>>/lists?key=<<your key>>&token=<<your token>>  "id" elements are the list ids.
#
# Author:
#   carmstrong

module.exports = (robot) ->
  robot.respond /card (new|main|side|release) (.*)/i, (msg) ->
    list = msg.match[1]
    cardName = msg.match[2]
    if not cardName.length
      msg.send "You must give the card a name"
      return
    if not process.env.HUBOT_TRELLO_KEY
      msg.send "Error: Trello app key is not specified"
    if not process.env.HUBOT_TRELLO_TOKEN
      msg.send "Error: Trello token is not specified"
    if not process.env.HUBOT_TRELLO_LIST
      msg.send "Error: Trello list ID is not specified"
    if not (process.env.HUBOT_TRELLO_KEY and process.env.HUBOT_TRELLO_TOKEN and process.env.HUBOT_TRELLO_LIST)
      return
    createCard msg, list, cardName
    
  robot.respond /show (new|main|side|release)/i, (msg) ->
    list = msg.match[1]
    showCards msg, list

createCard = (msg, list, cardName) ->
  Trello = require("node-trello")
  listid = switch list
    when 'new' then '5409fb04c5e14a561ae818a3';
    when 'main' then '53d8fbf05f8fc0cc4b9c2f7c';
    when 'side' then '53d92c5a7259e19b7c441cc9';
    when 'release' then '53d92eb95a287795dd198e37';
  t = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
  t.post "/1/cards", {name: cardName, idList: listid}, (err, data) ->
    if err
      msg.send "There was an error creating the card"
      return
    msg.send data.url

showCards = (msg, list) ->
  Trello = require("node-trello")
  t = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
  listid = switch list
    when 'new' then '5409fb04c5e14a561ae818a3';
    when 'main' then '53d8fbf05f8fc0cc4b9c2f7c';
    when 'side' then '53d92c5a7259e19b7c441cc9';
    when 'release' then '53d92eb95a287795dd198e37';
  t.get "/1/lists/"+listid, {cards: "open"}, (err, data) ->
    if err
      msg.send "There was an error showing the list."
      return

    msg.send "- " + card.name for card in data.cards
    