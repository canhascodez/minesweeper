# frozen_string_literal: true

require 'forwardable'

module Minesweeper
  class GameOver < StandardError; end

  # collection class for cells
  # rubocop:disable Naming/MethodParameterName
  class Board
    extend Forwardable
    def_delegators :@board, :each, :[]
    attr_reader :size, :board

    def initialize(size = [10, 10], mines = [])
      @size = size
      array = Array.new(size.last) { |y| Array.new(size.first) { |x| Cell.new(self, x, y) } }
      @board = mines.each_with_object(array) do |(x, y), memo|
        memo[y][x].mine = true
      end
    end

    def in_bounds?(x, y)
      (0...@size.first).cover?(x) && (0...@size.last).cover?(y)
    end

    def each_cell
      return enum_for(:each_cell) unless block_given?

      @board.each_with_index do |row, _y|
        row.each_with_index do |cell, _x|
          yield cell
        end
      end
    end

    def neighbors(cell)
      neighborhood = ([-1, 0, 1].repeated_permutation(2).to_a - [[0, 0]])
      neighborhood.filter_map do |dx, dy|
        coords = [cell.x + dx, cell.y + dy]
        next unless in_bounds?(*coords)

        @board[coords[1]][coords[0]]
      end
    end

    def immediate_neighbors(cell)
      deltas = [[0, 1], [1, 0], [-1, 0], [0, -1]]
      neighbors(cell).select do |neighbor|
        deltas.include?([neighbor.x - cell.x, neighbor.y - cell.y])
      end
    end

    def each_neighborhood = each_cell { yield neighbors(_1) }

    def contiguous_empty_cells(cell)
      return enum_for(:contiguous_empty_cells, cell) unless block_given?

      visited = Set.new
      queue = [cell]
      until queue.empty?
        current_cell = queue.shift
        next if visited.include?(current_cell) || !current_cell.revealable?

        visited << current_cell
        yield(current_cell)
        immediate_neighbors(current_cell).each { |neighbor| queue << neighbor if neighbor.revealable? }
      end
    end

    def reveal(x, y)
      cell = @board[x][y]
      return unless cell.hidden && !cell.flagged

      cell.hidden = false
      raise GameOver, 'You lose!' if cell.mine
      contiguous_empty_cells(cell) { _1.hidden = false } if cell.blank?
      raise GameOver, 'You win!' if game_won?
    end

    def game_won? = each_cell.all? { |cell| (cell.mine && cell.flagged) || !cell.hidden }

    def flag(x, y)
      @board[y][x].flagged = !@board[y][x].flagged
      raise GameOver, 'You win!' if game_won?
    end

    def to_s = @board.map { |row| row.join(' ') }.join("\n")
  end
  # rubocop:enable Naming/MethodParameterName
end
