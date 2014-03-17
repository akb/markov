{Transition} = require './transition'
{State} = require './state'

class Markov
  constructor: (options = {}) ->
    @state = new State(options.state)
    @transitions = new Transition.Collection(options.transitions)

  transition: (state) ->
    state = new State(state) unless state.valid?
    return unless state.valid()
    transition = @transitions.findOrCreate(@state, state)
    @state = transition.execute()

  reset: -> @state = new State(' ')

  random: ->
    @state = @transitions.randomCapital().head

  predict: ->
    choices = @transitions.findMany(@state)
    return unless choices.length
    sum = 0
    sum += t.count for t in choices
    random = Math.floor(Math.random() * sum)
    for t in choices
      random -= t.count
      return @state = t.tail if random <= 0 

  generate: ->
    buffer = []
    @random()
    buffer.push(next = @state)
    while next
      last = next
      next = @predict()
      unless next.match(/[',:;.!?\s]/) or last.match(/\s/)
        buffer.push(new State(' '))
      buffer.push(next) if next?
      break if next.match /[.!?]/
    return buffer

module.exports.Markov = Markov
