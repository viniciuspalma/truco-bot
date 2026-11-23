# frozen_string_literal: true

RSpec.describe TrucoBot::Game::Card do
  describe '.new' do
    it 'rejects ranks that are not in the Spanish deck' do
      expect { card(8, :golds) }.to raise_error(ArgumentError, /rank/)
    end

    it 'rejects unknown suits' do
      expect { card(1, :hearts) }.to raise_error(ArgumentError, /suit/)
    end

    it 'is a value object' do
      expect(card(7, :swords)).to eq(described_class[7, :swords])
    end
  end

  describe '#strength' do
    # From strongest to weakest; cards on the same line tie.
    let(:ladder) do
      [
        [card(1, :swords)],
        [card(1, :clubs)],
        [card(7, :swords)],
        [card(7, :golds)],
        described_class::SUITS.map { card(3, it) },
        described_class::SUITS.map { card(2, it) },
        [card(1, :golds), card(1, :cups)],
        described_class::SUITS.map { card(12, it) },
        described_class::SUITS.map { card(11, it) },
        described_class::SUITS.map { card(10, it) },
        [card(7, :clubs), card(7, :cups)],
        described_class::SUITS.map { card(6, it) },
        described_class::SUITS.map { card(5, it) },
        described_class::SUITS.map { card(4, it) }
      ]
    end

    it 'covers the whole deck' do
      expect(ladder.flatten).to match_array(TrucoBot::Game::Deck::CARDS)
    end

    it 'ties cards on the same step of the ladder' do
      expect(ladder.map { |step| step.map(&:strength).uniq.size }).to all(eq(1))
    end

    it 'strictly decreases down the ladder' do
      strengths = ladder.map { it.first.strength }
      expect(strengths).to eq(strengths.sort.reverse).and eq(strengths.uniq)
    end
  end

  describe '#beats?' do
    it 'ranks the 7 of swords above the 7 of golds' do
      expect(card(7, :swords).beats?(card(7, :golds))).to be(true)
      expect(card(7, :golds).beats?(card(7, :swords))).to be(false)
    end

    it 'ranks the 1 of swords above the 1 of clubs' do
      expect(card(1, :swords).beats?(card(1, :clubs))).to be(true)
      expect(card(1, :clubs).beats?(card(1, :swords))).to be(false)
    end

    it 'ranks the 1 of clubs above the 7 of swords' do
      expect(card(1, :clubs).beats?(card(7, :swords))).to be(true)
    end

    it 'ranks any 3 above the false aces and sevens' do
      expect(card(3, :cups).beats?(card(1, :golds))).to be(true)
      expect(card(3, :cups).beats?(card(7, :cups))).to be(true)
    end

    it 'does not let either of two equal cards win' do
      expect(card(3, :cups).beats?(card(3, :golds))).to be(false)
      expect(card(3, :golds).beats?(card(3, :cups))).to be(false)
    end
  end

  describe '#envido_value' do
    it 'counts number cards at face value' do
      expect(card(7, :cups).envido_value).to eq(7)
    end

    it 'counts face cards as zero' do
      expect([10, 11, 12].map { card(it, :golds).envido_value }).to eq([0, 0, 0])
    end
  end

  describe '#to_s' do
    it { expect(card(12, :cups).to_s).to eq('12 of cups') }
  end
end
