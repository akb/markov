class MarkovPrediction
  constructor: ->
    @markov = new MarkovChain
    $("#input").keyup(@handleKeyup.bind(this))
    $('#input').change(@handleChange.bind(this))

  handleKeyup: (event) ->
    entity = String.fromCharCode(event.keyCode)
    @markov.process(entity)
    @predict()

  handleChange: (event) ->
    $textarea = $(event.target)

  predict: ->
    $('#prediction').html(@markov.predict()?.join(''))

window.MarkovPrediction = MarkovPrediction