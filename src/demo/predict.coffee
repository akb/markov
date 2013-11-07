class MarkovPrediction
  constructor: ->
    @markov = new MarkovChain
    $("#input").keyup(@handleKeyup.bind(this))
    #$('#input').change(@handleChange.bind(this))

  handleKeyup: (event) ->
    entity = String.fromCharCode(event.keyCode)
    @markov.process(entity)
    @predict()

  handleChange: (event) ->
    $textarea = $(event.target)

  predict: ->
    remainingWord = ''
    state = @markov.state
    while state = state.next()
      remainingWord = remainingWord.concat(state.entity) 
    $('#prediction').html(remainingWord)

window.MarkovPrediction = MarkovPrediction
