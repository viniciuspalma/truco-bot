require 'spec_helper'

describe TrucoBot::Game::Deck do
  describe '#cards' do
    subject { described_class.new }

    it 'has a deck with 40 cards' do
      expect(subject.cards.size).to eq 40
    end

    it 'has 10 cards of clubs' do
      expect(subject.cards.count(&:is_club?)).to eq 10
    end

    it 'has 10 cards of golds' do
      expect(subject.cards.count(&:is_gold?)).to eq 10
    end

    it 'has 10 cards of cups' do
      expect(subject.cards.count(&:is_cup?)).to eq 10
    end

    it 'has 10 cards of swords' do
      expect(subject.cards.count(&:is_sword?)).to eq 10
    end
  end

  describe '#hand_out' do
    subject { described_class.new }

    it 'hand out a card' do
      subject.hand_out

      expect(subject.cards.size).to eq 39
    end
  end
end
