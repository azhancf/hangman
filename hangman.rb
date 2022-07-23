# frozen_string_literal: true

# words are read as one more character than they actually are
# eg. 'find' is 5 letters

# Computer that recieves the guess of the player and outputs information
class Computer
  attr_reader :player_guesses

  def initialize
    words = File.open('google-10000-english-no-swears.txt', 'r', &:readlines)
    @chosen_word = words.select { |word| word.length > 5 && word.length < 13 }.sample
    @player_guesses = 7
    @current_guess = Array.new(@chosen_word.length - 1)
    @incorrect_guesses = []
  end

  def check_guess(guess)
    # optional: check if the character has already been chosen?
    if @chosen_word.include?(guess)

      i = 0
      @chosen_word.each_char do |c|
        @current_guess[i] = guess if guess == c
        i += 1
      end

      puts
      if @chosen_word.strip == @current_guess.compact.join
        puts 'Congrats! You got the word!'
        puts "It was #{@chosen_word.strip}!"
        @player_guesses = 0
      else
        display_guess_info
      end
    else
      @incorrect_guesses.push(guess)
      @player_guesses -= 1
      @player_guesses = 0 if guess == 'exit'
      if @player_guesses.zero?
        puts 'Game over. '
        puts "The word was \"#{@chosen_word.strip}\"."
      else
        puts
        display_guess_info
      end
    end
  end

  private

  # TODO: print the correct one if you lose, for some reason underscores are not working
  # check if they already put it so player can't just infinitely spam the same letter that they already put

  def display_letters
    @current_guess.each do |c|
      if c.nil?
        print '-'
      else
        print c
      end
      print ' '
    end
  end

  def display_guess_info
    puts @player_guesses == 1 ? 'Oh no! You have 1 guess left!' : "You have #{@player_guesses} guesses left!"
    display_letters
    puts "Incorrect guesses: #{@incorrect_guesses.join(', ')}"
    puts
  end
end

# The player that plays Hangman
class Player
  def guess
    # check input validity (1 character). also should be case insensitive.
    player_guess = gets.chomp.to_s
    player_guess
  end
end

computer = Computer.new
player = Player.new

puts 'Try to guess characters in the word. Type exit to give up.'

computer.check_guess(player.guess) until computer.player_guesses.zero?
