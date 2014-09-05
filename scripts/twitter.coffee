# Description:
#   Allows users to post a tweet to Twitter using common shared
#   Twitter accounts.
#
#   Requires a Twitter consumer key and secret, which you can get by
#   creating an application here: https://dev.twitter.com/apps
#
#   Based on KevinTraver's twitter.coffee script: http://git.io/iCQPyA
#
#
# Commands:
#   hubot tweet <update> - posts the update to twitter
#
# Dependencies:
#   "twit": "1.1.8"
#
# Configuration:
#   HUBOT_TWITTER_CONSUMER_KEY
#   HUBOT_TWITTER_CONSUMER_SECRET
#   HUBOT_TWEETER_ACCESS_KEY
#   HUBOT_TWEETER_ACCESS_SECRET
#
# Author:
#   jhubert
#
# Repository:
#   https://github.com/jhubert/hubot-tweeter

Twit = require "twit"
config =
  consumer_key: process.env.HUBOT_TWITTER_CONSUMER_KEY
  consumer_secret: process.env.HUBOT_TWITTER_CONSUMER_SECRET
  access_token: process.env.HUBOT_TWEETER_ACCESS_KEY
  access_token_secret: process.env.HUBOT_TWEETER_ACCESS_SECRET

unless config.consumer_key
  console.log "Please set the HUBOT_TWITTER_CONSUMER_KEY environment variable."
unless config.consumer_secret
  console.log "Please set the HUBOT_TWITTER_CONSUMER_SECRET environment variable."
unless config.consumer_secret
  console.log "Please set the HUBOT_TWEETER_ACCESS_KEY environment variable."
unless config.consumer_secret
  console.log "Please set the HUBOT_TWEETER_ACCESS_SECRET environment variable."

module.exports = (robot) ->
  robot.respond /tweet$/i, (msg) ->
    msg.reply "You can't very well tweet an empty status, can ya?"
    return

  robot.respond /tweet\s(.+)$/i, (msg) ->

    update = msg.match[1].trim()

    unless update and update.length > 0
      msg.reply "You can't very well tweet an empty status, can ya?"
      return

    twit = new Twit
      consumer_key: config.consumer_key
      consumer_secret: config.consumer_secret
      access_token: config.access_token
      access_token_secret: config.access_token_secret

    twit.post "statuses/update",
      status: update
    , (err, reply) ->
      if err
        data = JSON.parse(err.data).errors[0]
        msg.reply "I can't do that. #{data.message} (error #{data.code})"
        return
      if reply['text']
        return msg.send "#{reply['user']['screen_name']} just tweeted: #{reply['text']}"
      else
        return msg.reply "Hmmm.. I'm not sure if the tweet posted. Check the account."
        