fs = require 'fs'

class Markov
  constructor: (options = {}) ->
    @state = options.state || ' '
    @transitions = []
    if options.transitions?
      @transitions.push(new Markov.Transition(t)) for t in options.transitions

  transition: (state) ->
    return unless state.match /[a-z' ]+/i
    for t in @transitions when t.tailMatches(state) and t.headMatches(@state)
      transition = t
    unless transition?
      transition = new Markov.Transition(@state, state)
      @transitions.push(transition)
    @state = transition.execute()

  reset: -> @state = ' '

  random: ->
    @state = @transitions[Math.floor(Math.random() * @transitions.length)].tail

  predict: ->
    choices = (t for t in @transitions when t.head is @state)
    return unless choices.length
    sum = 0
    sum += t.count for t in choices
    random = Math.floor(Math.random() * sum)
    for t in choices
      random -= t.count
      return @state = t.tail if random <= 0 

  generate: ->
    buffer = ''
    @random()
    next = ''
    next = @predict() until next.match(/\w+/)
    buffer += next[0].toUpperCase() + next.slice(1)
    while next
      last = next
      next = @predict()
      buffer += ' ' unless next.match(/[',:;.!?\s]/) or last.match(/\s/)
      buffer += next if next
      break if next.match /[.!?]/
    return buffer

class Markov.Transition
  constructor: (head, tail) ->
    if arguments.length is 1
      @tail = head.tail
      @count = head.count
      @head = head.head
    else
      @head = head
      @tail = tail
      @count = 0

  headMatches: (state) ->
    state.toLowerCase() is @head.toLowerCase()

  tailMatches: (state) ->
    state.toLowerCase() is @tail.toLowerCase()

  execute: ->
    @count++
    @tail

return unless process.argv

markov = null

seed = ->
  try
    fs.statSync('markov.json')
    markov = new Markov(JSON.parse(fs.readFileSync('markov.json').toString()))
    return console.log(markov.generate())
  catch
    markov = new Markov

  buffer = ''
  done = false

  process.stdin.setEncoding('utf8')

  process.stdin.on 'readable', ->
    chunk = process.stdin.read()
    return unless chunk?
    buffer += chunk

  process.stdin.on 'end', ->
    buffer = buffer.split(/\b/)
    for i in [0..buffer.length] #word, i in buffer
      if buffer[i] is "'"
        buffer[i-1] = buffer[i-1] + buffer[i] + buffer[i+1]
        buffer.splice(i, 2)
    done = true

  timer = setInterval ->
    if done and not buffer.length
      clearInterval(timer)
      fs.writeFileSync('markov.json', JSON.stringify(markov))
      console.log markov.generate()
    return unless buffer.length
    char = buffer[0]
    buffer = buffer.slice(1)
    char = char.replace(/"/g, '')
    char = char.replace(/\s+/g, ' ')
    return if char is ' '
    markov.transition(char)
  , 0

seed()
