require_relative 'display.rb'
require 'yaml'

class Hangman
include Display
    def initialize
        @word = ""
        @word = choose_word
        @lives = 6
        @incorrect_guess = Array.new()
        @word_size = ""
        ((@word.length) - 1).times do
            @word_size += '_ '
        end
    end

    def game_menu
        puts "Welcome to Hangman!"
        puts "Enter '1' to start a new game, Enter '2' to load a previous game!"
        choice = gets.chomp
        if choice.to_i.eql?(2)
            load_game
        end
        start
    end

    def start
        puts instructions
        #puts @word
        display_board
        make_guess
    end

    def choose_word
        all_words = File.readlines('google-10000-english-no-swears.txt')
        useable_words = Array.new()
        all_words.each do |word|
            next if (word.length-1)<5 || (word.length)>12
            useable_words = useable_words.push(word)
        end
        useable_words.sample
    end

    def instructions
        puts "A random top secret word of #{@word.length - 1} letters has been chosen. You have 6 guesses to get the top secret word. Each incorrect guess forms a body part starting with the head. Here is the starting figure. Once you have the word enter save or exit."
        puts HANGMAN_ZERO
    end

    def load_game
        unless Dir.exist?('saved_games')
            puts "No saved games found. Starting a new game!"
        end
        games = saved_games
        puts games
        deserialize(load_file(games))
    end

    def load_file(games)
        loop do
            puts "Enter which saved_game would like you to load:"
            load_file = gets.chomp
            return load_file if games.include?(load_file)
            puts "The game you requested does not exist."
        end
    end

    def deserialize(load_file)
        yaml  = YAML.load_file("./saved_games/#{load_file}.yml")
        self.word = yaml[0].word
        self.word_size = yaml[0].word_size
        self.lives = yaml[0].lives
        self.incorrect_guess = yaml[0].incorrect_guess
    end

    def saved_games
        puts "Saved games: "
        Dir['./saved_games/*'].map{|file| file.split('/')[-1].split('.')[0]}
    end

    def display_board(last_guess=nil)
        update_display(last_guess)
        puts @word_size
    end 

    def update_display(last_guess)
        new_word_size = @word_size.split
        new_word_size.each_with_index do |letter, index|
            if letter == '_' && @word[index] == last_guess
                new_word_size[index] = last_guess
            end
        end
        @word_size = new_word_size.join(' ')
    end

    def make_guess
        if @lives>0 
            puts "Please Enter your guess:"
            puts "You can also type \"save\" or \"exit\" to leave the game."
            guess = gets.chomp
            eval(guess)
        else
            puts "Game Over, You lose! The word was #{@word} :("
        end
    end

    def save_game
        puts "Enter the name of your save file:"
        save_file = gets.chomp
        Dir.mkdir('saved_games') unless Dir.exist?('saved_games') 
        File.open("./saved_games/#{save_file}.yml",'w'){|f| YAML.dump([]<<self,f)}
        puts "Your game has been saved."
    end

    def eval(guess)
        if !(@word_size.include?('_'))
            puts "You have won the Game!"
        elsif @incorrect_guess.include?(guess)
            puts "You have already guessed this letter!"
            make_guess
        else
            if guess.length == 1
                if @word.include?(guess)
                    puts "Correct Guess :)"
                    display_board(guess)
                    make_guess
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
                    display_board
                    make_guess
                end
            elsif guess == 'save'
                save_game
            elsif guess == 'exit'
                puts "Thank you for playing!"
            else
                puts "Your guess can only be one letter."
               make_guess
            end
        end
    end
end
game = Hangman.new()
game.game_menu
