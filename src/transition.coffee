class module.exports.Transition
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
