# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Minesweeper::Game do
  describe '#initialize' do
    it 'initializes a game with default values' do
      game = described_class.new
      expect(game.board.size).to eq [10, 10]
    end
  end
  describe '.new_random_mines' do
    it 'creates a random number of mines on the board' do
      game = described_class.new_random_mines([10, 10], 10)
      expect(game.board.each_cell.count(&:mine)).to eq 10
    end
  end
  describe '#run' do
    # the simplest test case is probably a 3x3 with a mine in the corner
    # this should let us test the basic reveal functionality
    let(:mines) { [[2, 2]] }
    let(:game) { described_class.new([3, 3], mines) }
    let(:input) do
      [
        Minesweeper::Input.new(:reveal, 0, 0),
        Minesweeper::Input.new(:flag, 2, 2)
      ]
    end
    before do
      allow(game).to receive(:get_input).and_return(*input)
    end
    it 'gets input in a loop until the game is over' do
      expect { game.run }.to output(/Game Over/).to_stdout
    end
  end

  describe '#get_input' do
    let(:game) { described_class.new }
    let(:input) { "0 0\n" }
    before do
      allow(game).to receive(:gets).and_return(input)
      allow(game).to receive(:retry_on_fail?).and_return(false)
    end
    it 'parses input into a type and coordinates' do
      expect(game.get_input).to have_attributes(type: :reveal, x: 0, y: 0)
    end

    it 'raises an error if the coordinates are out of bounds' do
      allow(game.board).to receive(:in_bounds?).and_return(false)
      expect { game.get_input }.to raise_error(ArgumentError)
    end

    it 'raises an error if the input cannot be parsed' do
      allow(game).to receive(:gets).and_return('invalid input')
      expect { game.get_input }.to raise_error(ArgumentError)
    end
  end
end
