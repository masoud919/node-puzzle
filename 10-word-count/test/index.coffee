assert = require 'assert'
WordCount = require '../lib'
fs = require 'fs'

helper = (input, expected, done) ->
  pass = false
  counter = new WordCount()

  counter.on 'readable', ->
    return unless result = this.read()
    assert.deepEqual result, expected
    assert !pass, 'Are you sure everything works as expected?'
    pass = true

  counter.on 'end', ->
    if pass then return done()
    done new Error 'Looks like transform fn does not work'

  counter.write input
  counter.end()


describe '10-word-count', ->

  it 'should count a single word', (done) ->
    input = 'test'
    expected = words: 1, lines: 1, chars: 4, bytes: 4
    helper input, expected, done

  it 'should count words in a phrase', (done) ->
    input = 'this is a basic test'
    expected = words: 5, lines: 1, chars: 20, bytes: 20
    helper input, expected, done

  it 'should count camel cased as multiple words', (done) ->
    input = 'ThiIsA camelCased testPhrase'
    expected = words: 7, lines: 1, chars: 28, bytes: 28
    helper input, expected, done

  it 'should count quoted characters as a single word', (done) ->
    input = '"this is one word!"'
    expected = words: 1, lines: 1, chars: 19, bytes: 19
    helper input, expected, done

  # Words/quoted phrases, must be separated by space
  it 'should not count quoted phrases with no proper separator', (done) ->
    input = 'Is"thisOneWord?? noIt\'sNot" "this is one word!!"  "this_is_not"mate "but this is;)"'
    expected = words: 2, lines: 1, chars: 83, bytes: 83
    helper input, expected, done

  it 'should count chained double quoted words with one space between', (done) ->
    input = '"this is oneWord" "two #$%words!" "three /what?"'
    expected = words: 3, lines: 1, chars: 48, bytes: 48
    helper input, expected, done

  it 'should correctly count empty input', (done) ->
    input = ''
    expected = words: 0, lines: 1, chars: 0, bytes: 0
    helper input, expected, done

  # NOTE: This input file is 4 lines not 3
  it 'should count multi line double quoted phrases and words', (done) ->
    fs.readFile "#{__dirname}/fixtures/3,7,46.txt", 'utf8', (err, data) ->
      if err then throw err
      expected = words: 7, lines: 4, chars: 46, bytes: 46
      helper data, expected, done

  # NOTE: This input file is 6 lines not 5
  it 'should count multi line camel cased words and ordinary words', (done) ->
    fs.readFile "#{__dirname}/fixtures/5,9,40.txt", 'utf8', (err, data) ->
      if err then throw err
      expected = words: 9, lines: 6, chars: 40, bytes: 40
      helper data, expected, done

  it 'should correctly count multi line with non-alphanumeric words', (done) ->
    fs.readFile "#{__dirname}/fixtures/5,3,41.txt", 'utf8', (err, data) ->
      if err then throw err
      expected = words: 3, lines: 5, chars: 41, bytes: 41
      helper data, expected, done

  it 'should correctly count multi line mix of non-alphanumeric, camel cased, double quoted, chained double quoted and ordinary words', (done) ->
    fs.readFile "#{__dirname}/fixtures/6,17,141.txt", 'utf8', (err, data) ->
      if err then throw err
      expected = words: 17, lines: 6, chars: 141, bytes: 141
      helper data, expected, done

  # !!!!!
  # Make the above tests pass and add more tests!
  # !!!!!
