# BART Transit Helper
#
#
util = require 'util'

bart_api_key = "MW9S-E7SL-26DU-VV8V"

# Get Real-Time Estimates
bart_api_etd = "http://api.bart.gov/api/etd.aspx?cmd=etd&key=#{bart_api_key}"
# &orig=RICH"

# Get a list of all BART stations
bart_api_stn = "http://api.bart.gov/api/stn.aspx?cmd=stns&key=#{bart_api_key}"

# JSON Dump
#msg.send "  #{console.log(util.inspect(json, false, null))}"
#return

module.exports = (robot) ->

  robot.respond /bart (stn|station|stations)/i, (msg) ->
    Parser = require("xml2js").Parser
    msg.http(bart_api_stn).get() (err, res, body) ->
      if err
        msg.send "BART API ERROR: #{err}"
        return
      (new Parser).parseString body, (err, json) ->
        if json['message'] and json['message']['error'] and json['message']['error']['text']
          msg.send "BART API ERROR: #{json['message']['error']['text']} (#{json['message']['error']['details']})"
          return
        msg.send "===== BART STATION LIST ====="
        for station in json['stations']['station']
          msg.send "  #{station['abbr']} - #{station['name']} (#{station['address']}, #{station['city']}, #{station['state']} #{station['zipcode']})"

  robot.respond /bart (etd|me) (.*)/i, (msg) ->
    Parser = require("xml2js").Parser
    msg.http("#{bart_api_etd}&orig=#{msg.match[2].toUpperCase()}").get() (err, res, body) ->
      if err
        msg.send "BART API ERROR: #{err}"
        return
      (new Parser).parseString body, (err, json) ->
        if json['message'] and json['message']['error'] and json['message']['error']['text']
          msg.send "BART API ERROR: #{json['message']['error']['text']} (#{json['message']['error']['details']})"
          return
        msg.send "===== BART ESTIMATED DEPARTURES FOR #{json['station']['abbr'].toUpperCase()} (#{json['station']['name'].toUpperCase()}) ====="
        for etd in json['station']['etd']
          msg.send "  #{etd['abbreviation']} (#{etd['destination']})"
          for estimate in etd['estimate']
            msg.send "    #{estimate['minutes']}m, #{estimate['length']} Car, #{estimate['direction']}bound, Platform #{estimate['platform']} (#{if estimate['bikeflag'] == 1 then 'Bikes OK' else 'NO Bikes'})"
