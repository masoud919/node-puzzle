through2 = require 'through2'

module.exports = ->
  words = 0
  lines = 1
  chars = 0
  bytes = 0


  transform = (chunk, encoding, cb) ->

    # Count lines
    lines = chunk.split(/\r\n|\r|\n/).length
    # Count characters
    chars = chunk.length
    # Count bytes
    bytes = Buffer.byteLength chunk, 'utf8'

    # Replace new line characters with space
    chunk = chunk.replace /\r\n|\r|\n/g, ' '

    # Look for a word (at least one character) in double quotes                                     "(.+?)"
    # Words are separated by space so look for                                                      \s"(.+?)"\s
    # Word could be at the beginning or end of the string                                            (\s|^)"(.+?)"(\s|$)
    # It could be a chain of double quoted words with one space between, like "word1" "word2" etc.  ((\s|^)"(.+?)"(\s|$))("(.+?)"(\s|$))*
    dQuotesRegExp = /((\s|^)"(.+?)"(\s|$))("(.+?)"(\s|$))*/g
    matchesArr = chunk.match dQuotesRegExp

    # If any match found
    if Array.isArray matchesArr
      # Count double quoted words
      # An item in matchesArr could be a chain of double quoted words,
      # so find words one by one and remove them from the matchesArr item
      dQSubRegExp = /(\s|^)"(.+?)"(\s|$)/
      for m in matchesArr
        while m.search(dQSubRegExp) != -1
          words++
          m = m.replace dQSubRegExp, ' '

      # Remove all double quoted words from the chunk (replace with space)
      chunk = chunk.replace dQuotesRegExp, ' '

    # Trim and replace multiple spaces with one
    chunk = chunk.trim().replace /\s{2,}/g, ' '
    # Get possible words in an array
    tokens = chunk.split ' '
    for t in tokens
      # If not an alphanumeric word, skip
      if t.search(/^[a-z0-9]+$/i) == -1
        continue
      # Count single word or camel cased words
      words += t.replace(/([A-Z])/g, ' $1').trim().split(' ').length

    return cb()


  flush = (cb) ->
    this.push {words, lines, chars, bytes}
    this.push null
    return cb()

  return through2.obj transform, flush