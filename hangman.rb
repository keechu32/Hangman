require_relative 'display.rb'

class Hangman
include Display
    def initialize
        @letters = ('a'..'z').to_a
        @word = choose_word
        @lives = 6
        @incorrect_guess = Array.new()
    end

    def start
        puts "Welcome to Hangman!"
        puts instructions
        puts @word
        display_board
        make_guess
    end

    def choose_word
        all_words = File.readlines('google-10000-english-no-swears.txt')
        useable_words = Array.new()
        all_words.each do |word|
            next if word.length<5 || word.length>12
            useable_words = useable_words.push(word)
        end
        useable_words.sample
    end

    def instructions
        puts "A random top secret word of #{@word.length} letters has been chosen. You have 6 guesses to get the top secret word. Each incorrect guess forms a body part starting with the head. Here is the starting figure."
        puts HANGMAN_ZERO
    end

    def display_board
        word_size = ""
        @word.size.times do
            word_size += "_ " 
        end
        puts word_size
    end 

    def make_guess
        if @lives>0
            puts "Please Enter your guess:"
            puts "You can also type \"save\" or \"exit\" to leave the game."
            guess = gets.chomp
            eval(guess)
        else
            puts "Game Over, You lose! :("
        end
    end

    def eval(guess)
       if guess.length == 1
        if @word.include?(guess)
            puts "Correct Guess :)"
        else
            @lives-=1
            @incorrect_guess = @incorrect_guess.push(guess)
            puts "That was an incorrect guess :(\nTry again"
            p @incorrect_guess
            case @lives
            when 5
                puts HANGMAN_ONE
            when 4
                puts HANGMAN_TWO
            when 3
                puts HANGMAN_THREE
            when 2
                puts HANGMAN_FOUR
            when 1
                puts HANGMAN_FIVE
                puts "This is your last guess, think carefully!"
            when 0
                puts HANGMAN_SIX
            end
            make_guess
        end
       elsif guess == 'save'
           
       elsif guess == 'exit'
           
       else
            make_guess
       end

    end
end
game = Hangman.new()
game.start
