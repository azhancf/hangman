# frozen_string_literal: true

require 'json'

# '\n' is appended to the chosen word from reading the file
# TODO: check input validity
# check if they already put it so player can't just infinitely spam the same letter that they already put
# optional: check if the character has already been chosen?

# Can update the guesses
module UpdateGuessable
  private

  def update_correct_guesses(guess)
    i = 0
    @chosen_word.each_char do |c|
      @current_guess[i] = guess if guess == c
      i += 1
    end
  end

  def update_incorrect_guesses(guess)
    @incorrect_guesses.push(guess)
  end

  def update_player_guesses(guess)
    @player_guesses -= 1
    @player_guesses = 0 if guess == 'exit'
  end
end

# Can display the guess information
module DisplayGuessable
  private

  def display_guess_info
    puts @player_guesses == 1 ? 'Oh no! You have 1 guess left!' : "You have #{@player_guesses} guesses left!"
    display_letters
    puts "Incorrect guesses: #{@incorrect_guesses.join(', ')}"
    puts
  end

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
end

# Can print the game over messages
module GameOverMessageable
  private

  def win_game
    puts 'Congrats! You got the word!'
    puts "It was \"#{@chosen_word.strip}\"!"
    @player_guesses = 0
  end

  def lose_game
    puts 'Game over. '
    puts "The word was \"#{@chosen_word.strip}\"." unless @incorrect_guesses.include?('save')
  end
end

# can convert to or from JSON
module JSONable
  def load_game(game_id)
    # TODO: provide error checking to see if the file exists before reading to prevent errors
    json_data = File.open("data/#{game_id}.json", 'r', &:readline)
    data = JSON.parse(json_data)
    # TODO: saving and loading game files
    # there is definitely an easier or better way to do this
    # that automatically does it for each key/variable
    # i don't have the mental energy to figure it out right now
    @chosen_word = data['chosen_word']
    @player_guesses = data['player_guesses']
    @current_guess = data['current_guess']
    @incorrect_guesses = data['incorrect_guesses']
  end

  private

  def to_json(*_args)
    JSON.dump({
                chosen_word: @chosen_word,
                player_guesses: @player_guesses,
                current_guess: @current_guess,
                incorrect_guesses: @incorrect_guesses
              })
  end
end

# Can save the state of the game in a JSON file
module SaveGameable
  private

  def save_data_file(number_of_games)
    Dir.mkdir('data') unless Dir.exist?('data')
    filename = "data/#{number_of_games}.json"
    File.open(filename, 'w') do |file|
      file.puts to_json
    end
  end

  def write_to_number_games_file(num)
    File.open('number_games.txt', 'w') do |file|
      file.print(num)
    end
  end

  def save_game
    if !File.exist?('number_games.txt')
      write_to_number_games_file('0')
    else
      number_of_games = File.open('number_games.txt', 'r', &:readlines).join.to_i
      write_to_number_games_file(number_of_games + 1)
    end

    puts "Your saved file ID number is #{number_of_games}"

    save_data_file(number_of_games)
  end
end

# Computer that recieves the guess of the player and outputs information
class Computer
  include UpdateGuessable
  include JSONable
  include GameOverMessageable
  include SaveGameable
  include DisplayGuessable

  attr_reader :player_guesses

  def initialize
    words = File.open('google-10000-english-no-swears.txt', 'r', &:readlines)
    @chosen_word = words.select { |word| word.length > 5 && word.length < 13 }.sample
    @player_guesses = 7
    @current_guess = Array.new(@chosen_word.length - 1)
    @incorrect_guesses = []
  end

  def check_guess(guess)
    if guess == 'save'
      save_game
    else
      puts
      if @chosen_word.include?(guess)
        update_correct_guesses(guess)
        @chosen_word.strip == @current_guess.compact.join ? win_game : display_guess_info
      else
        update_incorrect_guesses(guess)
        update_player_guesses(guess)
        @player_guesses.zero? ? lose_game : display_guess_info
      end
    end
  end
end

# The player that plays Hangman
class Player
  def guess
    gets.chomp.to_s
  end
end

computer = Computer.new
player = Player.new

puts 'Type "load" to load a game, hit enter to create new game.'
if gets.chomp == 'load'
  puts
  puts 'Enter the ID of the game you wish to load.'
  game_id = gets.chomp
  computer.load_game(game_id)
  puts 'Game loaded'
  puts
end

puts
puts 'Try to guess characters in the word. Type "exit" to give up; type "save" to save.'

computer.check_guess(player.guess) until computer.player_guesses.zero?
