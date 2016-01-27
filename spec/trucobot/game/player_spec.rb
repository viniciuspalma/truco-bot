require 'spec_helper'

describe TrucoBot::Game::Player do
  let(:card_one) { TrucoBot::Game::Card.new('1'.to_sym, 'clubs'.to_sym) }
  let(:card_two) { TrucoBot::Game::Card.new('2'.to_sym, 'clubs'.to_sym) }
  let(:card_three) { TrucoBot::Game::Card.new('3'.to_sym, 'clubs'.to_sym) }

  describe '#hand' do
    subject { described_class.new('username') }

    it { expect(subject.hand).to be_empty}
  end

  describe '#receive_card' do
    context 'when the hand is not full' do
      subject { described_class.new('username') }

      it 'should include the added card' do
        expect(subject.receive_card(card_one)).to include card_one
      end

      it 'should has only an item in the hand' do
        subject.receive_card(card_one)

        expect(subject.hand.size).to eq 1
      end

      it 'should accept 3 items' do
        subject.receive_card(card_one)
        subject.receive_card(card_two)
        subject.receive_card(card_three)

        expect(subject.hand).to contain_exactly card_one, card_two, card_three
      end
    end

    context 'when the hand is full' do
      subject { described_class.new('username') }

      it 'should return `nil`' do
        subject.receive_card(card_one)
        subject.receive_card(card_two)
        subject.receive_card(card_three)

        expect(subject.receive_card(card_one)).to be_nil
      end
    end
  end

  describe '#pick_card' do
    context 'when card position is valid' do
      subject { described_class.new('username') }

      it 'should return the selected card in the last position' do
        subject.receive_card(card_one)
        subject.receive_card(card_two)
        subject.receive_card(card_three)

        expect(subject.pick_card(0)).to eq [card_two, card_three, card_one]
      end
    end

    context 'when card position is invalid' do
      subject { described_class.new('username') }

      it 'should return `nil`' do
        expect(subject.pick_card(3)).to be_nil
      end
    end
  end

  describe '#use_card' do
    context 'when has cards on hand' do
      subject { described_class.new('username') }

      it 'should return picked card' do
        subject.receive_card(card_one)
        subject.receive_card(card_two)
        subject.receive_card(card_three)
        subject.pick_card 1

        expect(subject.use_card).to eq card_two
      end
    end

    context 'when has not cards on hand' do
      subject { described_class.new('username') }

      it 'should return `nil`' do
        expect(subject.use_card).to be_nil
       end
    end
  end
end
