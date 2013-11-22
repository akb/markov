RESET_ENTITIES   = [' ', "'", '.', '"', ',', '!', ':', ';', '?', '/']
IGNORED_ENTITIES = ['\n']
REWIND_ENTITIES  = ['\b']

class State
  constructor: (options={}) ->
    @entity = options.entity || null
    @transitions = new Transition.Set(options.transitions)
    @parent = options.parent

  process: (entity) ->
    unless transition = @transitions.find(entity)[0]
      node = new State(entity:entity, parent:this)
      transition = new Transition(head:node, tail:this)
      @transitions.append(transition)
    transition.strength += 1
    transition.head

  nextStrongest: ->
    transitions = @transitions.strongest()
    return unless transitions.length
    return transitions[0].head if transitions.length is 1
    return transitions[Math.floor(Math.random() * transitions.length)].head

  next: ->
    roll = Math.random()
    count = 0.0
    for i, p in @transitions.probabilities()
      return @transitions.get(i).head if (count += p) >= roll

  previous: ->
    transition = @parent.transitions.find (t) -> t.head is this
    if (transition.strength -= 1) < 1
      @parent.transitions.remove(transition)

class Transition
  constructor: (options={}) ->
    @tail     = options.tail     || null
    @head     = options.head     || null
    @strength = options.strength || 0

class Transition.Set
  constructor: (transitions) ->
    @transitions = transitions || []

  get: (i) -> @transitions[i]

  sum: ->
    console.log @transitions
    sum = 0
    sum += t.strength for t in @transitions
    sum

  probabilities: ->
    sum = @sum()
    console.log sum
    strength / sum for t in @transitions

  find: (entity) ->
    t for i, t of @transitions when t.head.entity is entity

  append: (transition) ->
    @transitions.push(transition)

  maxStrength: ->
    max = 0
    max = t.strength for t in @transitions when t.strength > max
    max

  strongest: ->
    max = @maxStrength()
    t for t in @transitions when t.strength is max

  remove: (transition) ->
    delete @transitions[@transitions.indexOf(transition)]

class MarkovChain
  constructor: (options={}) ->
    @nullstate = options.nullstate || new State
    @state     = options.state     || @nullstate

  reset: ->
    @state = @nullstate

  rewind: ->
    @state = @state.back()

  process: (entity) ->
    return if entity in IGNORED_ENTITIES
    return @reset() if entity in RESET_ENTITIES
    return @rewind() if entity in REWIND_ENTITIES
    @state = @state.process(entity)

  predict: ->
    prediction = []
    state = @state
    return unless state.entity
    prediction.push(state.entity) while state = state.next()
    return prediction

window.State       = State
window.Transition  = Transition
window.MarkovChain = MarkovChain
