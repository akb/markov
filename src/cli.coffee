return unless process.argv?

fs = require 'fs'
{Markov} = require './markov'

commands = {}

commands.create = (inputfile) ->
  try
    fs.statSync(inputfile)
    markov = new Markov(JSON.parse(fs.readFileSync(inputfile).toString()))
    process.stdout.write(markov.generate() + '\n')
    process.exit(0)
  catch
    process.stderr.write("#{inputfile} does not exist\n")
    process.exit(1)

commands.learn = ->
  buffer = ''
  inputComplete = false
  markov = new Markov

  process.stdin.setEncoding('utf8')

  process.stdin.on 'readable', ->
    chunk = process.stdin.read()
    return unless chunk?
    buffer += chunk

  process.stdin.on 'end', ->
    buffer = buffer.split(/\b/)
    for i in [0..buffer.length]
      if buffer[i] is "'"
        buffer[i-1] = buffer[i-1] + buffer[i] + buffer[i+1]
        buffer.splice(i, 2)
    inputComplete = true

  timer = setInterval ->
    if inputComplete and not buffer.length
      clearInterval(timer)
      process.stdout.write(JSON.stringify(markov))
    return unless buffer.length
    char = buffer[0]
    buffer = buffer.slice(1)
    char = char.replace(/"/g, '')
    char = char.replace(/\s+/g, ' ')
    return if char is ' '
    markov.transition(char)
  , 0

argv = require('minimist')(process.argv.slice(2))
commands[argv._[0]]?.apply(this, argv._[1...])
