# BART Transit Helper
#
# bart (stn|stns|station|stations) list - Requests a list of all of the BART stations.
# bart (stn|stns|station|stations) info <station> - Requests detailed information on the specified station.
# bart (stn|stns|station|stations) access <station> - Requests access/neighborhood information for the specified station.
# bart (etd|me) <station> - Requests current departure information.
# bart ver - Requests current API version information.
# bart bsa - Requests current advisory information.
# bart elev - Requests current elevator infromation.

util = require("util")
Parser = require("xml2js").Parser
#HtmlParser = require("htmlparser")

bart_api_key = "MW9S-E7SL-26DU-VV8V"
bart_api_url = "http://api.bart.gov/api/"

format_bart_api_url = (uri, cmd, add) ->
  url = "#{bart_api_url}#{uri}.aspx?cmd=#{cmd}&key=#{bart_api_key}#{if add then '&'+add.join('&') else ''}"
  console.log("format_bart_api_url(): '#{url}'")
  url

format_http_error = (err) ->
  "HTTP ERROR: #{err}"

is_bart_api_error = (json) ->
  return true if json['message'] and json['message']['error'] and json['message']['error']['text'] and json['message']['error']['text'] != ''
  return false

is_bart_api_warning = (json) ->
  return true if json['message'] and json['message']['warning'] and json['message']['warning'] != ''
  return false

format_bart_api_error = (json) ->
  "BART API ERROR: #{json['message']['error']['text']} (#{json['message']['error']['details']})"

format_bart_api_warning = (json) ->
  "BART API WARNING: #{json['message']['warning']}"

format_bart_bsa = (bsa) ->
  "  #{bsa['type']} ##{bsa['@']['id']} @ #{bsa['posted']}\n    #{bsa['description']}"


module.exports = (robot) ->

  robot.respond /bart bsa/i, (msg) ->
    strings = []
    msg.http(format_bart_api_url("bsa", "bsa")).get() (err, res, body) ->
      return msg.send format_http_error(err) if err
      (new Parser).parseString body, (err, json) ->
        dump_json(json)

        return msg.send format_bart_api_error(json) if is_bart_api_error(json)
        return msg.send format_bart_api_warning(json) if is_bart_api_warning(json)

        strings.push "===== BART ADVISORY INFORMATION  ====="
        if json['bsa']
          if json['bsa'] instanceof Array
            for bsa in json['bsa']
              strings.push format_bart_bsa(bsa)
          else
            strings.push format_bart_bsa(json['bsa'])
        else
          strings.push "No advisory information is available at this time!"

        msg.send strings.join('\n')
        return

  robot.respond /bart elev/i, (msg) ->
    strings = []
    msg.http(format_bart_api_url("bsa", "elev")).get() (err, res, body) ->
      return msg.send format_http_error(err) if err
      (new Parser).parseString body, (err, json) ->
        dump_json(json)

        return msg.send format_bart_api_error(json) if is_bart_api_error(json)
        return msg.send format_bart_api_warning(json) if is_bart_api_warning(json)

        strings.push "===== BART ELEVATOR INFORMATION ====="
        if json['bsa']
          if json['bsa'] instanceof Array
            for bsa in json['bsa']
              strings.push format_bart_bsa(bsa)
          else
            strings.push format_bart_bsa(json['bsa'])
        else
          strings.push "No elevator information is available at this time!"

        msg.send strings.join('\n')
        return

  robot.respond /bart (stn|stns|station|stations) (list|access|info)\s*(.*)?$/i, (msg) ->
    strings = []
    action = msg.match[2]
    stn = msg.match[3]

    if action.match /list/i
      msg.http(format_bart_api_url("stn", "stns")).get() (err, res, body) ->
        return msg.send format_http_error(err) if err
        (new Parser).parseString body, (err, json) ->
          dump_json(json)
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
          dump_json(json)
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
          strings.push "#{info['name']} Food: #{info['food']}" if info['food']
          strings.push "#{info['name']} Shopping: #{info['shopping']}" if info['shopping']
          strings.push "#{info['name']} Attractions: #{info['attraction']}" if info['attraction']

          msg.send strings.join('\n')
          return

    if action.match /access/i
      return msg.send "ERROR: You must specify a station to get access information for it!" if stn == ''
      msg.http(format_bart_api_url("stn", "stnaccess", ["orig=#{msg.match[3].toUpperCase()}"])).get() (err, res, body) ->
        return msg.send format_http_error(err) if err
        (new Parser).parseString body, (err, json) ->
          dump_json(json)
          return msg.send format_bart_api_error(json) if is_bart_api_error(json)
          return msg.send format_bart_api_warning(json) if is_bart_api_warning(json)

          strings = []
          strings.push "===== BART STATION ACCESS INFORMATION ====="

          msg.send strings.join('\n')
          return


  robot.respond /bart (ver|version)/i, (msg) ->
    msg.http(format_bart_api_url("etd", "ver")).get() (err, res, body) ->
      return msg.send format_http_error(err) if err
      (new Parser).parseString body, (err, json) ->
        dump_json(json)
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
        dump_json(json)
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


dump_json = (json) ->
  console.log(util.inspect(json, false, null))


###

------------
HOLDING AREA
------------

test_func = (one, two, cb) ->
  console.log("#{one}, #{two}")
  cb("three", "four")

test_func '1', '2', (three, four) ->
  console.log("#{three}, #{four}")
  return


extract_text = (item) ->
  result = ''
  if item instanceof Array
    for i in item
      result += extract_text(i)
    return result

  console.log(item)

  # recurse if this is text
  if item.type == 'text'
    result += item.raw
    if item.children
      for child in item.children
        console.log(child)
        result += extract_text(child)

  # don't recurse if this is an anchor tag
  if item.type == 'tag' and item.name == 'a'
    result += item.attribs.href

  return result

strip_html = (html) ->
  handler = new HtmlParser.DefaultHandler()
  parser = new HtmlParser.Parser(handler)
  parser.parseComplete(html)
  return extract_text(handler.dom)

###