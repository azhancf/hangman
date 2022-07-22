# frozen_string_literal: true

words = File.open('google-10000-english-no-swears.txt', 'r', &:readlines)

# words are read as one more character than they actually are
# eg. 'find' is 5 letters
chosen_word = words.select { |word| word.length > 5 && word.length < 13 }.sample

puts chosen_word
