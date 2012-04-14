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
#msg.send "#{console.log(util.inspect(json, false, null))}"
#return

module.exports = (robot) ->
  robot.respond /test a/i, (msg) ->
    strings = []
    strings.push "one"
    strings.push "two"
    msg.send strings.join('\n')

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
        strings = []
        strings.push "===== BART STATION LIST ====="
        for station in json['stations']['station']
          strings.push "  #{station['abbr']} - #{station['name']} (#{station['address']}, #{station['city']}, #{station['state']} #{station['zipcode']})"
        msg.send strings.join('\n')

  robot.respond /bart (etd|me) (.*)/i, (msg) ->
    Parser = require("xml2js").Parser
    msg.http("#{bart_api_etd}&orig=#{msg.match[2].toUpperCase()}").get() (err, res, body) ->
      if err
        msg.send "BART API ERROR: #{err}"
        return
      (new Parser).parseString body, (err, json) ->
        msg.send "#{console.log(util.inspect(json, false, null))}"

        strings = []

        if json['station']
          strings.push "===== BART ESTIMATED DEPARTURES FOR #{json['station']['abbr'].toUpperCase()} (#{json['station']['name'].toUpperCase()}) ====="

        if json['message'] and json['message']['error'] and json['message']['error']['text']
          strings.push "ERROR: #{json['message']['error']['text']} (#{json['message']['error']['details']})"
        else
          if json['message'] and json['message']['warning']
            strings.push "WARNING: #{json['message']['warning']}"
          else
            if json['station']['etd'] instanceof Array
              for etd in json['station']['etd']
                strings.push process_bart_etd etd
            else
              strings.push process_bart_etd json['station']['etd']
        msg.send strings.join('\n')


process_bart_etd = (etd) ->
  strings = []
  strings.push "  #{etd['abbreviation']} (#{etd['destination']})"
  if etd['estimate'] instanceof Array
    for estimate in etd['estimate']
      strings.push format_bart_etd estimate
  else
    strings.push format_bart_etd etd['estimate']
  strings.join('\n')


format_bart_etd = (estimate) ->
  "    #{estimate['minutes']}#{if estimate['minutes'] != 'Leaving' then 'm' else ''}, #{estimate['length']} Car, #{estimate['direction']}bound, Platform #{estimate['platform']} (#{if estimate['bikeflag'] == 1 then 'Bikes OK' else 'NO Bikes'})"

