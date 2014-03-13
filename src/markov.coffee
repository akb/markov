RESET_ENTITIES   = ['.', '!', ':', ';', '?', '\n']
IGNORED_ENTITIES = [' ']
#REWIND_ENTITIES  = ['\b']

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

  next: -> @transitions.decide()

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
    sum = 0
    sum += t.strength for t in @transitions
    sum

  probabilities: ->
    sum = @sum()
    t.strength / sum for t in @transitions

  decide: ->
    roll = Math.random()
    count = 0.0
    for p, i in @probabilities()
      return @get(i).head if (count += p) >= roll

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
    #return @rewind() if entity in REWIND_ENTITIES
    @state = @state.process(entity)

  predict: ->
    prediction = []
    state = @nullstate
    prediction.push(state.entity) while state = state.next()
    return prediction

#window.State       = State
#window.Transition  = Transition
#window.MarkovChain = MarkovChain

rl = require('readline').createInterface
  input:    process.stdin
  output:   process.stdout
  terminal: false

trie = new MarkovChain

started = false
queue = []

start = ->
  started = true
  while queue.length
    line = queue.shift()
    trie.process(word) for word in line.split /\b/
  started = false

rl.on 'line', (line) ->
  queue.push(line)
  start() unless started

rl.on 'close', -> generate()

generate = -> console.log trie.predict().join(' ')
