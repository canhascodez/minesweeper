# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Minesweeper::Board do
  let(:board) { described_class.new([10, 10]) }

  describe '#initialize' do
    it 'initializes a board with default values' do
      expect(board.size).to eq [10, 10]
    end
  end

  describe '#in_bounds?' do
    it 'returns true if the coordinates are within the board' do
      expect(board.in_bounds?(0, 0)).to be true
    end

    it 'returns false if the coordinates are outside the board' do
      expect(board.in_bounds?(10, 10)).to be false
    end
  end

  describe '#each_cell' do
    it 'yields each cell in the board' do
      cells = []
      board.each_cell { cells << _1 }
      expect(cells.size).to eq 100
    end
  end

  describe '#neighbors' do
    context 'when the cell is in the corner of the board' do
      let(:cell) { board[0][0] }

      it 'returns an array of neighboring cells' do
        cell = board[0][0]
        neighbors = board.neighbors(cell)
        expect(neighbors).to be_an Array
        expect(neighbors.size).to eq 3
      end
    end

    context 'when the cell is in the middle of the board' do
      let(:cell) { board[1][1] }
      it 'returns an array of neighboring cells' do
        neighbors = board.neighbors(cell)
        expect(neighbors).to be_an Array
        expect(neighbors.size).to eq 8
      end
    end
  end

  describe '#immediate_neighbors' do
    context 'when the cell is in the corner of the board' do
      let(:cell) { board[0][0] }
      it 'returns an array of immediate neighboring cells' do
        cell = board[0][0]
        neighbors = board.immediate_neighbors(cell)
        expect(neighbors).to be_an Array
        expect(neighbors.size).to eq 2
      end
    end

    context 'when the cell is in the middle of the board' do
      let(:cell) { board[1][1] }
      it 'returns an array of immediate neighboring cells' do
        neighbors = board.immediate_neighbors(cell)
        expect(neighbors).to be_an Array
        expect(neighbors.size).to eq 4
      end
    end
  end

  describe '#each_neighborhood' do
    it 'yields each cell and its neighbors' do
      cells = []
      board.each_neighborhood { cells << _1 }
      expect(cells.size).to eq 100
    end
  end

  describe '#contiguous_empty_cells' do
    it 'yields each empty cell and its neighbors' do
      cells = []
      board.contiguous_empty_cells(board[0][0]) { cells << _1 }
      expect(cells.size).to eq 100
    end

    context 'when the cell is not revealable' do
      before do
        board[1][1].flagged = true
      end
      it 'does not yield the cell' do
        cells = []
        board.contiguous_empty_cells(board[1][1]) { cells << _1 }
        expect(cells.size).to eq 0
      end

      it 'can yield all the cells around the flagged cell' do
        cells = []
        board.contiguous_empty_cells(board[0][0]) { cells << _1 }
        expect(cells.size).to eq 99
      end
    end

    context 'when there are interior empty cells' do
      before do
        board[0][1].mine = true
        board[1][0].mine = true
        board[1][1].mine = true
        board[1][2].mine = true
        board[2][1].mine = true
      end
      it 'does not yield the interior empty cells' do
        cells = []
        board.contiguous_empty_cells(board[5][5]) { cells << _1 }
        expect(cells.size).to eq 94
      end
    end
  end

  describe '#reveal' do
    context 'when the cell is flagged' do
      before do
        board[0][0].flagged = true
      end
      it 'does not reveal the cell' do
        board.reveal(0, 0)
        expect(board[0][0].hidden).to be true
      end
    end

    context 'when the cell is a mine' do
      before do
        board[0][0].mine = true
      end
      it 'raises a GameOver error' do
        expect { board.reveal(0, 0) }.to raise_error(Minesweeper::GameOver, 'You lose!')
      end
    end

    context 'when the cell is empty' do
      before do
        [[0, 2], [1, 2], [2, 2], [2, 1], [2, 0]].each do |x, y|
          board[x][y].mine = true
        end
      end
      it 'reveals all contiguous empty cells' do
        board.reveal(0, 0)
        expect(board[0][0].hidden).to be false
        expect(board[0][1].hidden).to be false
        expect(board[1][0].hidden).to be false
        expect(board[1][1].hidden).to be false
      end
    end
  end

  describe '#flag' do
    it 'toggles the flagged status of the cell' do
      board.flag(0, 0)
      expect(board[0][0].flagged).to be true
      board.flag(0, 0)
      expect(board[0][0].flagged).to be false
    end
  end

  describe '#game_won?' do
    it 'returns false when the game is not won' do
      expect(board.game_won?).to be false
    end

    it 'returns true when the game is won' do
      board.each_cell { _1.mine = true }
      board.each_cell { _1.flagged = true }
      expect(board.game_won?).to be true
    end
  end
end
