# frozen_string_literal: true

module Minesweeper
  # A cell in the Minesweeper game.
  Cell = Struct.new(:board, :x, :y, :hidden, :mine, :flagged, :adjacent_mines) do
    # rubocop does not love the `x` and `y` parameter names
    # rubocop:disable Naming/MethodParameterName
    def initialize(board, x, y, **options)
      defaults = { hidden: true, mine: false, flagged: false, adjacent_mines: 0 }
      defaults.merge!(options)
      super(board, x, y, *defaults.values_at(:hidden, :mine, :flagged, :adjacent_mines))
    end
    # rubocop:enable Naming/MethodParameterName

    def neighbors = board.neighbors(self)

    def to_s
      # isn't this cute?
      return '⚑' if flagged
      return '⬛' if hidden
      return '💣' if mine

      adjacent_mines.zero? ? ' ' : adjacent_mines.to_s
    end

    def blank? = !mine && !flagged

    def revealable? = !mine && !flagged

    def adjacent_mines = @adjacent_mines ||= board.neighbors(self).count(&:mine)

    def inspect = "#<Cell:#{object_id} #{x},#{y} #{self}>"
  end
end
