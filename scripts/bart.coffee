# BART Transit Helper
#
# bart stn list - List Stations
# bart stn info <station> - Show Station Information
# bart stn access <station> - Show Station Access Information
# bart me <station> - Get Real-Time Estimated Departures

util = require("util")
Parser = require("xml2js").Parser

bart_api_key = "MW9S-E7SL-26DU-VV8V"
bart_api_url = "http://api.bart.gov/api/"

# API Version Information
bart_api_ver = "#{bart_api_url}etd.aspx?cmd=ver&key=#{bart_api_key}"

# Get Real-Time Estimates
bart_api_etd = "#{bart_api_url}etd.aspx?cmd=etd&key=#{bart_api_key}"

# Get a list of all BART stations
bart_api_stn = "#{bart_api_url}stn.aspx?cmd=stns&key=#{bart_api_key}"

# Get a BART stations info
bart_api_stn_info = "#{bart_api_url}stn.aspx?cmd=stninfo&key=#{bart_api_key}"

# Get a BART stations access
bart_api_stn_access = "#{bart_api_url}stn.aspx?cmd=stnaccess&key=#{bart_api_key}"


module.exports = (robot) ->

  robot.respond /bart (stn|station|stations) (list|access|info)\s*(.*)?$/i, (msg) ->
    strings = []
    action = msg.match[2]
    stn = msg.match[3]

    if action.match /list/i
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

    if action.match /info/i
      if stn
        strings.push "info #{stn}"
      else
        strings.push "ERROR: You must specify a station to get information for it!"
      msg.send strings.join('\n')

    if action.match /access/i
      if stn
        strings.push "access #{stn}"
      else
        strings.push "ERROR: You must specify a station to get access information for it!"
      msg.send strings.join('\n')



  robot.respond /bart (ver|version)/i, (msg) ->
    msg.http(bart_api_ver).get() (err, res, body) ->
      if err
        msg.send "BART API ERROR: #{err}"
        return
      (new Parser).parseString body, (err, json) ->
        strings = []
        strings.push "API Version: #{json['apiVersion']}"
        strings.push "Copyright: #{json['copyright']}"
        strings.push "License: #{json['license']}"
        msg.send strings.join('\n')


  robot.respond /bart (etd|me) (.*)/i, (msg) ->
    msg.http("#{bart_api_etd}&orig=#{msg.match[2].toUpperCase()}").get() (err, res, body) ->
      if err
        msg.send "BART API ERROR: #{err}"
        return
      (new Parser).parseString body, (err, json) ->
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
  strings.push "  :station:#{etd['abbreviation']} (#{etd['destination']})"
  if etd['estimate'] instanceof Array
    for estimate in etd['estimate']
      strings.push format_bart_etd estimate
  else
    strings.push format_bart_etd etd['estimate']
  strings.join('\n')


format_bart_etd = (estimate) ->
  "    #{estimate['minutes']}#{if estimate['minutes'] != 'Leaving' then 'm' else ''}, #{estimate['length']} Car, #{estimate['direction']}bound, Platform #{estimate['platform']} (#{if estimate['bikeflag'] == 1 then ':bike:' else 'NO Bikes'})"


dump_json = (msg, json) ->
  msg.send "#{console.log(util.inspect(json, false, null))}"
