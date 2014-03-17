{State} = require './state'

class Transition
  constructor: (head, tail) ->
    unless tail?
      @tail = new State(head.tail)
      @count = head.count
      @head = new State(head.head)
    else
      @head = head
      @tail = tail
      @count = 0

  matches: (head, tail) ->
    unless tail?
      return @headMatches(head)
    @headMatches(head) and @tailMatches(tail)

  headMatches: -> State::matches.apply(@head, arguments)

  tailMatches: -> State::matches.apply(@tail, arguments)

  execute: ->
    @count++
    @tail

class Transition.Collection
  constructor: (options={}) ->
    @collection = []
    if options.collection?
      for t in options.collection
        @create(t) 

  create: (head, tail) ->
    transition = new Transition(head, tail)
    @collection.push(transition)
    transition

  find: (head, tail) ->
    for t in @collection
      if t.matches(head, tail)
        return t

  findMany: (head, tail) ->
    t for t in @collection when t.matches(head, tail)

  findOrCreate: (head, tail) ->
    t = @find(head, tail)
    t = @create(head, tail) unless t?
    t

  random: ->
    @collection[Math.floor(Math.random() * @collection.length)]

  randomCapital: ->
    subset = (t for t in @collection when t.head.match(/^[A-Z]/))
    subset[Math.floor(Math.random() * subset.length)]

module.exports.Transition = Transition
