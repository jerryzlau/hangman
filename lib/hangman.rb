class Hangman
  attr_reader :guesser, :referee, :board

  def initialize(players) #= {:guesser => player1, :referee => player2})
    @guesser = players[:guesser]
    @referee = players[:referee]
  end

  def setup
    secret_word_length = @referee.pick_secret_word
    @guesser.register_secret_length(secret_word_length)
    @board = Array.new(secret_word_length)
  end

  def take_turn
    guess = @guesser.guess(board)
    index = @referee.check_guess(guess)
    update_board
    @guesser.handle_response(guess, index)
  end

  def update_board

  end

end

class HumanPlayer
end

class ComputerPlayer

  attr_reader :candidate_words

  def initialize(dictionary = File.readlines("lib/dictionary.txt"))
    @dictionary = dictionary.map(&:chomp)
  end

  def pick_secret_word
    @word = @dictionary.sample
    @length = @word.length
  end

  def register_secret_length(word_length)
    @candidate_words = @dictionary.select {|w| w.length == word_length}
  end

  def check_guess(letter)
    answer = []
    @word.chars.each_with_index do |char, idx|
      if char == letter
        answer << idx
      end
    end
    answer
  end

  def guess(board)
    letter_hash = {}
    letters = @candidate_words.join.chars
    letters.each do |letter|
      letter_hash[letter] = letters.count(letter)
    end
    @letter_count = letter_hash.sort_by {|k,v| v}

    if board.uniq == [nil]
      @letter_count.pop.first
    else
      @letter_count.pop
      @letter_count.pop.first 
    end
  end

  def handle_response(letter, index)
    result = []
    if index == []
      result = @candidate_words.reject {|word| word.include?(letter)}
    else
      length = @candidate_words.first.length
      @candidate_words.each do |word|
        compare = (0..length-1).select {|idx| word[idx] == letter}
        result << word if compare == index
      end
    end
    @candidate_words = result
  end


end
