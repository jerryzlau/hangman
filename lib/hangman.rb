require "byebug"

class Hangman
  attr_reader :guesser, :referee, :board

  def initialize(guesser = HumanPlayer.new, referee = ComputerPlayer.new)
    @guesser = guesser
    @referee = referee
    @board = board
    @dictionary = File.readlines("lib/dictionary.txt").map(&:chomp)
    @wrong_guesses = 0
  end

  def setup
    secret_word_length = @referee.pick_secret_word
    @guesser.register_secret_length(secret_word_length)
    @board = Array.new(secret_word_length)
  end

  def take_turn
    guess = @guesser.guess(board)
    if guess == false
      puts "Seems like there is no such word in the dictionary!"
      exit
    end
    index = @referee.check_guess(guess)
    update_board(guess,index)
    if index.empty?
      @wrong_guesses += 1
    end
    @guesser.handle_response(guess, index)
  end

  def update_board(guess,index)
    index.each {|idx| @board[idx] = guess}
  end

  def won?
    !@board.include?(nil)
  end

  def display_hangman(counter)
    if counter == 0
      puts "------"
      puts "|"
      puts "|"
      puts "|"
      puts "|"
      puts "|"
      puts "------------"
    elsif counter == 1
      puts "------"
      puts "|    |"
      puts "|    O"
      puts "|"
      puts "|"
      puts "|"
      puts "------------"
    elsif counter == 2
      puts "------"
      puts "|    |"
      puts "|    O"
      puts "|   /|\\"
      puts "|"
      puts "|"
      puts "------------"
    elsif counter == 3
      puts "------"
      puts "|    |"
      puts "|    O"
      puts "|   /|\\"
      puts "|    |"
      puts "|"
      puts "------------"
    elsif counter == 4
      puts "------"
      puts "|    |"
      puts "|    O"
      puts "|   /|\\"
      puts "|    |"
      puts "|   / \\"
      puts "------------"
      puts "You dead. Your death sentence was \"#{@referee.secret_word}\""
      exit
    end
  end

  def play
    if @guesser.class == HumanPlayer
      puts "Hello #{@guesser.name}! Welcome to your death WA HA HA!"
    end
    setup
    until won?
      display = @board.map do |el|
        el.nil? ? " _ " : el
      end
      display_hangman(@wrong_guesses)
      p display.join("")
      take_turn
    end

    puts "The word was \"#{board.join('')}\""
  end

end

class HumanPlayer
  attr_reader :name

  def initialize(name = "Human")
    @name = name
  end

  def guess(board)
    puts "Guess a letter of the word"
    gets.chomp.downcase
  end

  def check_guess(letter)
    puts "AI has guessed #{letter}"
    puts "Is that letter included in your word?"
    answer = gets.chomp.downcase.split('').first
    if answer == "y"
      puts "At which indicies are they?"
      return gets.chomp.split(",").map(&:to_i)
    else
      return []
    end
  end

  def register_secret_length(secret)
    puts "The secret word is #{secret} characters long"
  end

  def handle_response(guess, pos)
    puts "#{guess} at #{pos}"
  end

  def pick_secret_word
    puts "What is the length of the word?"
    gets.chomp.to_i
  end

end

class ComputerPlayer
  attr_reader :candidate_words
  attr_accessor :secret_word

  def initialize(dictionary = File.readlines("lib/dictionary.txt"))
    @dictionary = dictionary.map(&:chomp)
    @guessed_letters = []
  end

  def pick_secret_word
    @secret_word = @dictionary.sample
    @length = @secret_word.length
  end

  def register_secret_length(word_length)
    @candidate_words = @dictionary.select {|w| w.length == word_length}
  end

  def check_guess(letter)
    answer = []
    @secret_word.chars.each_with_index do |char, idx|
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

    guessed_letter = letter_hash
    return false if guessed_letter == {}

    guessed_letter.reject! { |letter, _count| board.include?(letter) }
    guessed_letter = guessed_letter.max_by { |_letter, count| count }[0]
    @guessed_letters << guessed_letter
    guessed_letter
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

if $0 == __FILE__
  computer = ComputerPlayer.new
  puts "Who is playing the game? (computer/your name)"
  input = gets.chomp
  if input == "computer"
    Hangman.new(computer,HumanPlayer.new).play
  else
    human = HumanPlayer.new(input)
    Hangman.new(human, computer).play
  end
end
