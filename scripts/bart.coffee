# BART Transit Helper
#
# bart (stn|station|stations) list - List Stations
# bart (stn|station|stations) info <station> - Show Station Information
# bart (stn|station|stations) access <station> - Show Station Access Information
# bart (etd|me) <station> - Get Real-Time Estimated Departures

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

format_bart_api_url = (uri, cmd, add) ->
  url = "#{bart_api_url}#{uri}.aspx?cmd=#{cmd}&key=#{bart_api_key}#{if add then '&'+add.join('&') else ''}"
  console.log("format_bart_api_url(): '#{url}'")
  url

format_http_error = (err) ->
  "HTTP ERROR: #{err}"


is_bart_api_error = (json) ->
  return true if json['message'] and json['message']['error'] and json['message']['error']['text'] and json['message']['error']['text'] != ''
  return false

format_bart_api_error = (json) ->
  "BART API ERROR: #{json['message']['error']['text']} (#{json['message']['error']['details']})"


is_bart_api_warning = (json) ->
  return true if json['message'] and json['message']['warning'] and json['message']['warning'] != ''
  return false

format_bart_api_warning = (json) ->
  "BART API WARNING: #{json['message']['warning']}"


###
test_func = (one, two, cb) ->
  console.log("#{one}, #{two}")
  cb("three", "four")

test_func '1', '2', (three, four) ->
  console.log("#{three}, #{four}")
  return
###


module.exports = (robot) ->

  robot.respond /bart (stn|station|stations) (list|access|info)\s*(.*)?$/i, (msg) ->
    strings = []
    action = msg.match[2]
    stn = msg.match[3]

    if action.match /list/i
      msg.http(format_bart_api_url("stn", "stns")).get() (err, res, body) ->
        return msg.send format_http_error(err) if err
        (new Parser).parseString body, (err, json) ->
          return msg.send format_bart_api_error(json) if is_bart_api_error(json)
          return msg.send format_bart_api_warning(json) if is_bart_api_warning(json)

          strings.push "===== BART STATION LIST ====="
          for station in json['stations']['station']
            strings.push "  #{station['abbr']} - #{station['name']} (#{station['address']}, #{station['city']}, #{station['state']} #{station['zipcode']})"
          msg.send strings.join('\n')
          return

    if action.match /info/i
      return msg.send "ERROR: You must specify a station to get information for it!" if stn == ''
      msg.http(format_bart_api_url("stn", "stninfo", ["orig=#{msg.match[3].toUpperCase()}"])).get() (err, res, body) ->
        return msg.send format_http_error(err) if err
        (new Parser).parseString body, (err, json) ->
          return msg.send format_bart_api_error(json) if is_bart_api_error(json)
          return msg.send format_bart_api_warning(json) if is_bart_api_warning(json)

          info = json['stations']['station']
          strings.push "===== BART STATION INFORMATION ====="
          strings.push "#{info['name']} (#{info['abbr']}) [#{info['link']}]"
          strings.push "#{info['address']}"
          strings.push "#{info['city']}, #{info['state']}  #{info['zipcode']}"
          if info['north_platforms']['platform']
            strings.push "North Platform: #{info['north_platforms']['platform']}"
            if info['north_routes']['route']
              for route in info['north_routes']['route']
                strings.push "  #{route}"
          if info['south_platforms']['platform']
            strings.push "South Platform: #{info['south_platforms']['platform']}"
            if info['south_routes']['route']
              for route in info['south_routes']['route']
                strings.push "  #{route}"
          strings.push info['platform_info'] if info['platform_info']
          strings.push info['intro'] if info['intro']
          strings.push "Cross-Street: #{info['cross_street']}" if info['cross_street']
          strings.push "Food: #{info['food']}" if info['food']
          strings.push "Shopping: #{info['shopping']}" if info['shopping']
          strings.push "Attractions: #{info['attraction']}" if info['attraction']

          msg.send strings.join('\n')
          return

    if action.match /access/i
      return msg.send "ERROR: You must specify a station to get access information for it!" if stn == ''
      msg.http(format_bart_api_url("stn", "stnaccess", ["orig=#{msg.match[3].toUpperCase()}"])).get() (err, res, body) ->
        return msg.send format_http_error(err) if err
        (new Parser).parseString body, (err, json) ->
          return msg.send format_bart_api_error(json) if is_bart_api_error(json)
          return msg.send format_bart_api_warning(json) if is_bart_api_warning(json)

          info = json['stations']['station']
          dump_json(msg, info)

          strings = []
          strings.push "===== BART STATION ACCESS INFORMATION ====="
          dump_json(msg, json)

          msg.send strings.join('\n')
          return


  robot.respond /bart (ver|version)/i, (msg) ->
    msg.http(format_bart_api_url("etd", "ver")).get() (err, res, body) ->
      return msg.send format_http_error(err) if err
      (new Parser).parseString body, (err, json) ->
        return msg.send format_bart_api_error(json) if is_bart_api_error(json)
        return msg.send format_bart_api_warning(json) if is_bart_api_warning(json)

        strings = []
        strings.push "API Version: #{json['apiVersion']}"
        strings.push "Copyright: #{json['copyright']}"
        strings.push "License: #{json['license']}"
        msg.send strings.join('\n')


  robot.respond /bart (etd|me) (.*)/i, (msg) ->
    msg.http(format_bart_api_url("etd", "etd", ["orig=#{msg.match[2].toUpperCase()}"])).get() (err, res, body) ->
      return msg.send format_http_error(err) if err
      (new Parser).parseString body, (err, json) ->
        return msg.send format_bart_api_error(json) if is_bart_api_error(json)
        return msg.send format_bart_api_warning(json) if is_bart_api_warning(json)

        strings = []
        if json['station']
          strings.push "===== BART ESTIMATED DEPARTURES FOR #{json['station']['abbr'].toUpperCase()} (#{json['station']['name'].toUpperCase()}) ====="
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


dump_json = (msg, json) ->
  msg.send "#{console.log(util.inspect(json, false, null))}"
