{Transition} = require './transition'

class module.exports.Markov
  constructor: (options = {}) ->
    @state = options.state or ' '
    @transitions = []
    if options.transitions?
      @transitions.push(new Transition(t)) for t in options.transitions

  transition: (state) ->
    return unless state.match /[a-z' ]+/i
    for t in @transitions
      if t.tailMatches(state) and t.headMatches(@state)
        transition = t
    unless transition?
      transition = new Transition(@state, state)
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
