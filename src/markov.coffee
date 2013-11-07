RESET_ENTITYS   = ['\n', ' ', "'", '.', '"', ',', '!', ':', ';', '?', '/']
IGNORED_ENTITYS = ['\n']

class State
  constructor: (options={}) ->
    @entity = options.entity || null
    @transitions = new Transition.Set(options.transitions)

  process: (entity) ->
    unless transition = @transitions.find(entity)[0]
      node = new State(entity:entity)
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
    probabilities = @probabilities()
    @transitions[i].head for p, i in probabilities when (count += p) >= roll

class Transition
  constructor: (options={}) ->
    @tail     = options.tail     || null
    @head     = options.head     || null
    @strength = options.strength || 0

class Transition.Set
  constructor: (transitions) ->
    @transitions = transitions || []

  get: (i) -> @tansitions[i]

  sum: -> (t.strength for t in @transitions).reduce(((s, v) -> s + v), 0)

  probabilities: ->
    sum = @sum()
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

class MarkovChain
  constructor: (options={}) ->
    @nullstate = options.nullstate || new State
    @state     = options.state     || @nullstate

  reset: ->
    @state = @nullstate

  process: (entity) ->
    return if entity in IGNORED_ENTITYS
    return @reset() if entity in RESET_ENTITYS
    @state = @state.process(entity)

  predict: ->
    prediction = []
    state = @state
    return unless state.entity
    prediction.push(state.entity) while state = state.next()
    return prediction

window.State = State
window.Transition = Transition
window.MarkovChain = MarkovChain
