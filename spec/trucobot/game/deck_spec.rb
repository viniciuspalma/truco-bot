# frozen_string_literal: true

RSpec.describe TrucoBot::Game::Deck do
  subject(:deck) { described_class.new(random: Random.new(42)) }

  let(:alice) { player('alice') }
  let(:bob) { player('bob') }

  it 'holds the 40 distinct cards of the Spanish deck' do
    expect(described_class::CARDS.size).to eq(40)
    expect(described_class::CARDS.uniq.size).to eq(40)
  end

  it 'has ten cards of each suit' do
    expect(described_class::CARDS.map(&:suit).tally.values).to all(eq(10))
  end

  it 'shuffles reproducibly from a seed' do
    other = described_class.new(random: Random.new(42))
    expect(Array.new(40) { deck.draw }).to eq(Array.new(40) { other.draw })
  end

  describe '#draw' do
    it 'removes a card from the deck' do
      expect { deck.draw }.to change(deck, :size).from(40).to(39)
    end

    it 'raises once the deck is empty' do
      40.times { deck.draw }
      expect { deck.draw }.to raise_error(TrucoBot::Error, /empty/)
    end
  end

  describe '#deal' do
    subject(:hands) { deck.deal([alice, bob]) }

    it 'gives three cards to each player' do
      expect(hands.transform_values(&:size)).to eq(alice => 3, bob => 3)
    end

    it 'deals six different cards' do
      expect(hands.values.flatten.uniq.size).to eq(6)
      expect(deck.size).to eq(34)
    end

    it 'deals one card at a time, starting with the first player' do
      replay = described_class.new(random: Random.new(42))
      order = Array.new(6) { replay.draw }
      expect(hands[alice]).to eq(order.values_at(0, 2, 4))
      expect(hands[bob]).to eq(order.values_at(1, 3, 5))
    end
  end
end
