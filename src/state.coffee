class State
  constructor: (@entity=' ') ->
    @entity = @entity.entity if @entity.entity

  valid: ->
    @entity.match /[a-z' ]+/i

  matches: (state) ->
    @entity.toLowerCase() is state.entity.toLowerCase()

  match: -> @entity.match.apply(@entity, arguments)

  toString: -> @entity

module.exports.State = State
