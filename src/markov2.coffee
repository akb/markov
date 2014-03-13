class MarkovChain
  constructor: ->
    @states = {}

  input: (entity) ->
    @state.hit(entity)
    @state = new State(entity) unless @state = @states[entity]

class State
  constructor: (@entity=null) ->
    @transitions = new Transition.Set

  hit: @transitions.hit.bind(@transitions)

class Transition
  constructor: (@tail, @head, @probability) ->

class Transition.Set
  constructor: ->
    @transitions = {}

  get: (entity) -> @transitions[entity]
