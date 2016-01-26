require 'spec_helper'

describe TrucoBot::Game::Card do
  describe '#to_sym' do
    subject { described_class.new('1'.to_sym, 'swords'.to_sym) }
    it { expect(subject.to_sym).to eq '1_swords'.to_sym }
  end

  describe '#is_club?' do
    context 'when the card\'s suit is clubs' do
      subject { described_class.new('1'.to_sym, 'clubs'.to_sym) }

      it { expect(subject.is_club?).to be_truthy }
    end

    context 'when the card\'s suit is not clubs' do
      subject { described_class.new('1'.to_sym, 'golds'.to_sym) }

      it { expect(subject.is_club?).to be_falsy }
    end
  end

  describe '#is_gold?' do
    context 'when the card\'s suit is golds' do
      subject { described_class.new('1'.to_sym, 'golds'.to_sym) }

      it { expect(subject.is_gold?).to be_truthy }
    end

    context 'when the card\'s suit is not golds' do
      subject { described_class.new('1'.to_sym, 'clubs'.to_sym) }

      it { expect(subject.is_gold?).to be_falsy }
    end
  end

  describe '#is_cup?' do
    context 'when the card\'s suit is cups' do
      subject { described_class.new('1'.to_sym, 'cups'.to_sym) }

      it { expect(subject.is_cup?).to be_truthy }
    end

    context 'when the card\'s suit is not cups' do
      subject { described_class.new('1'.to_sym, 'swords'.to_sym) }

      it { expect(subject.is_cup?).to be_falsy }
    end
  end

  describe '#is_sword?' do
    context 'when the card\'s suit is swords' do
      subject { described_class.new('1'.to_sym, 'swords'.to_sym) }

      it { expect(subject.is_sword?).to be_truthy }
    end

    context 'when the card\'s suit is not swords' do
      subject { described_class.new('1'.to_sym, 'cups'.to_sym) }

      it { expect(subject.is_sword?).to be_falsy }
    end
  end
end
