# frozen_string_literal: true

require_relative './board'
require_relative './cell'

module Minesweeper
  Input = Struct.new(:type, :x, :y) do
    def flag? = type == :flag
    def reveal? = type == :reveal
  end
  # handles input and game rules
  class Game
    attr_reader :board

    def self.new_random_mines(size = [10, 10], count = 20)
      mines = []
      mine_generator = Enumerator.new do |y|
        loop do
          mine = [rand(size.first), rand(size.last)]
          next if mines.include?(mine)

          mines << mine
          y << mine
        end
      end
      new(size, mine_generator.take(count))
    end

    def initialize(size = [10, 10], mines = [])
      @board = Board.new(size, mines)
    end

    def run
      loop do
        puts board
        input = get_input
        board.send(input.type, input.x, input.y)
      end
    rescue GameOver => e
      puts 'Game Over!'
      puts board
      puts e.message
      # puts 'New game? (y/n)'
      # input = gets.chomp.downcase
      # self.class.new_random_mines if input == 'y'
    end

    def retry_on_fail? = true

    INPUT_MESSAGE = <<~INPUT_MESSAGE
      Flag a mine by entering 'f' followed by the column (y) and row (x) numbers
      Reveal a cell by entering the column and row numbers.
    INPUT_MESSAGE

    def get_input
      puts INPUT_MESSAGE
      # not sure if it's best to be more flexible with the inputs here
      gets.chomp.match(/\A(f)?\s*(\d+)\s+(\d+)\z/i) do |matchdata|
        type = (matchdata.captures.first =~ /f/i) ? :flag : :reveal
        x, y = matchdata.captures[1..2].map(&:to_i)
        raise ArgumentError, 'Coordinates out of bounds.' unless @board.in_bounds?(x, y)

        return Input.new(type, x, y)
      end
      raise ArgumentError, "Couldn't parse input."
    rescue ArgumentError => e
      raise unless retry_on_fail?

      puts e.message, 'Try again.'
      retry
    end
  end
end
