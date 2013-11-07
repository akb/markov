// Generated by CoffeeScript 1.6.3
(function() {
  var MarkovPrediction;

  MarkovPrediction = (function() {
    function MarkovPrediction() {
      this.markov = new MarkovChain;
      $("#input").keyup(this.handleKeyup.bind(this));
    }

    MarkovPrediction.prototype.handleKeyup = function(event) {
      var entity;
      entity = String.fromCharCode(event.keyCode);
      this.markov.process(entity);
      return this.predict();
    };

    MarkovPrediction.prototype.handleChange = function(event) {
      var $textarea;
      return $textarea = $(event.target);
    };

    MarkovPrediction.prototype.predict = function() {
      var remainingWord, state;
      remainingWord = '';
      state = this.markov.state;
      while (state = state.next()) {
        remainingWord = remainingWord.concat(state.entity);
      }
      return $('#prediction').html(remainingWord);
    };

    return MarkovPrediction;

  })();

  window.MarkovPrediction = MarkovPrediction;

}).call(this);
