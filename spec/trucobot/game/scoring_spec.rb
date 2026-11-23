# frozen_string_literal: true

RSpec.describe TrucoBot::Game::Scoring do
  describe '.envido' do
    it 'adds 20 to two cards of the same suit' do
      expect(described_class.envido([card(7, :golds), card(6, :golds), card(3, :cups)])).to eq(33)
    end

    it 'counts face cards as zero in a pair' do
      expect(described_class.envido([card(12, :swords), card(10, :swords), card(1, :cups)])).to eq(20)
    end

    it 'uses the best two of three cards of the same suit' do
      expect(described_class.envido([card(7, :clubs), card(5, :clubs), card(6, :clubs)])).to eq(33)
    end

    it 'uses the highest card when no two cards share a suit' do
      expect(described_class.envido([card(4, :golds), card(7, :cups), card(12, :swords)])).to eq(7)
    end

    it 'can be zero' do
      expect(described_class.envido([card(10, :golds), card(11, :cups), card(12, :swords)])).to eq(0)
    end
  end

  describe '.flor?' do
    it 'is true for three cards of one suit' do
      expect(described_class.flor?([card(1, :cups), card(2, :cups), card(12, :cups)])).to be(true)
    end

    it 'is false otherwise' do
      expect(described_class.flor?([card(1, :cups), card(2, :cups), card(12, :golds)])).to be(false)
    end
  end

  describe '.flor' do
    it 'adds 20 to all three cards' do
      expect(described_class.flor([card(7, :cups), card(6, :cups), card(5, :cups)])).to eq(38)
    end
  end
end
