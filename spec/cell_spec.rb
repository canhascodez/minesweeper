# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Minesweeper::Cell do
  let(:board) { Minesweeper::Board.new([10, 10]) }
  let(:cell) { described_class.new(board, 0, 0) }

  describe '#initialize' do
    it 'initializes a cell with default values' do
      expect(cell.hidden).to be true
      expect(cell.mine).to be false
      expect(cell.flagged).to be false
      expect(cell.adjacent_mines).to eq 0
    end
  end

  describe '#neighbors' do
    it 'returns an array of neighboring cells' do
      neighbors = cell.neighbors
      expect(neighbors).to be_an Array
      expect(neighbors.size).to eq 3
    end

    context 'when the cell is in the middle of the board' do
      let(:cell) { board[1][1] }
      it 'returns an array of neighboring cells' do
        neighbors = cell.neighbors
        expect(neighbors).to be_an Array
        expect(neighbors.size).to eq 8
      end
    end
  end

  describe '#to_s' do
    it 'returns a string representation of the cell' do
      expect(cell.to_s).to eq '▪'
    end

    it 'returns a string representation of the cell when hidden is false' do
      cell.hidden = false
      expect(cell.to_s).to eq '□'
    end

    it 'returns a string representation of the cell when flagged is true' do
      cell.flagged = true
      expect(cell.to_s).to eq '⚑'
    end

    it 'returns a string representation of the cell when mine is true' do
      cell.mine = true
      cell.hidden = false
      expect(cell.to_s).to eq '💣'
    end
  end

  describe '#blank?' do
    it 'returns true if the cell is not a mine or flagged' do
      expect(cell.blank?).to be true
    end
  end

  describe '#adjacent_mines' do
    it 'returns the number of adjacent mines' do
      expect(cell.adjacent_mines).to eq 0
    end
    context 'with adjacent mines' do
      before { board[0][1].mine = true }
      it 'returns the number of adjacent mines' do
        expect(cell.adjacent_mines).to eq 1
      end
    end
    context 'all mines' do
      let(:board) { Minesweeper::Board.new([3, 3], [[0, 0], [0, 1], [0, 2], [1, 0], [1, 2], [2, 0], [2, 1], [2, 2]]) }
      let(:cell) { board[1][1] }
      it 'returns the number of adjacent mines' do
        expect(cell.adjacent_mines).to eq 8
      end
    end
  end
end
