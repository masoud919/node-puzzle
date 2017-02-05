fs = require 'fs'
readline = require 'readline'
stream = require 'stream'

exports.countryIpCounter = (countryCode, cb) ->
  return cb() unless countryCode

  # Create stream	
  instream = fs.createReadStream "#{__dirname}/../data/geo.txt"
  outstream = new stream
  readL = readline.createInterface instream, outstream

  # Read line by line and count
  counter = 0
  readL.on 'line', (line) ->
    line = line.split '\t'
    # GEO_FIELD_MIN, GEO_FIELD_MAX, GEO_FIELD_COUNTRY
    # line[0],       line[1],       line[3]
    if line[3] == countryCode then counter += +line[1] - +line[0]

  # return error on error
  readL.on 'error', (err) ->
    cb err

  # return counter when done reading
  readL.on 'close', () ->
    cb null, counter