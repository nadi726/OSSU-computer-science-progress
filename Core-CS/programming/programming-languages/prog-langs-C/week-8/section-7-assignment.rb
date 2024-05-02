## Solution template for Guess The Word practice problem (section 7)

require_relative './section-7-provided'

class ExtendedGuessTheWordGame < GuessTheWordGame
  ## YOUR CODE HERE
end

class ExtendedSecretWord < SecretWord
  Special_Chars = "!\"#$%&'()*+,-./:;<=>?@[\]^_`{|}~ "
  def initialize word
    self.word = word
    @wrong_guesses = []
    get_initial_pattern
  end
  
  def is_solved?
    self.word.downcase == self.pattern.downcase
  end

  def get_initial_pattern
    self.pattern = ''
    self.word.each_char do |c|
      if Special_Chars.include? c
        self.pattern << c
      else
        self.pattern << "-"
      end
    end
  end
  
  def valid_guess? guess
    guess.length == 1 and !(Special_Chars.include? guess)
  end

  def guess_letter! letter
    found = super(letter) or super(letter.swapcase)
    if !found
      if @wrong_guesses.include? letter.downcase
        return true
      else
        @wrong_guesses.push(letter.downcase)
      end
    end
  found
  end
end


## Change to `false` to run the original game
if true
  ExtendedGuessTheWordGame.new(ExtendedSecretWord).play
else
  GuessTheWordGame.new(SecretWord).play
end

