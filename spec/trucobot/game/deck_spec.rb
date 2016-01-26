require 'spec_helper'

describe TrucoBot::Game::Deck do
  let(:deck) { described_class.new }

  describe '#cards' do
    it 'has a deck with 40 cards' do
      expect(deck.cards.size).to eq 40
    end

    it 'has 10 cards of clubs' do
      expect(deck.cards.count(&:is_club?)).to eq 10
    end

    it 'has 10 cards of golds' do
      expect(deck.cards.count(&:is_gold?)).to eq 10
    end

    it 'has 10 cards of cups' do
      expect(deck.cards.count(&:is_cup?)).to eq 10
    end

    it 'has 10 cards of swords' do
      expect(deck.cards.count(&:is_sword?)).to eq 10
    end
  end
end
