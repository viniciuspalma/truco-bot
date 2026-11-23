require 'spec_helper'

describe TrucoBot::Game::EvaluateRound do
  let(:player_one) { TrucoBot::Game::Player.new('Player One') }
  let(:player_two) { TrucoBot::Game::Player.new('Player Two') }
  let(:card_1_swords) { TrucoBot::Game::Card.new('1'.to_sym, 'swords'.to_sym) }
  let(:card_7_golds) { TrucoBot::Game::Card.new('7'.to_sym, 'golds'.to_sym) }
  let(:card_5_golds) { TrucoBot::Game::Card.new('5'.to_sym, 'golds'.to_sym) }
  let(:card_2_cups) { TrucoBot::Game::Card.new('2'.to_sym, 'cups'.to_sym) }

  describe '#call' do
    context 'when has only one high card' do
      let(:plays) {
        [TrucoBot::Game::Play.new(player_one, card_1_swords),
        TrucoBot::Game::Play.new(player_two, card_5_golds)]
      }

      it 'return play with the high card' do
        expect(described_class.new(plays).call).to eq([plays.first])
      end
    end

    context 'when has many high cards' do
      let(:plays) {
        [TrucoBot::Game::Play.new(player_one, card_1_swords),
        TrucoBot::Game::Play.new(player_two, card_7_golds)]
      }

      it 'return play with the high card' do
        expect(described_class.new(plays).call).to eq([plays.first])
      end
    end

    context 'when hasn\'t high cards' do
      let(:plays) {
        [TrucoBot::Game::Play.new(player_one, card_2_cups),
        TrucoBot::Game::Play.new(player_two, card_5_golds)]
      }

      it 'return highest play' do
        expect(described_class.new(plays).call).to eq([plays.first])
      end
    end

    context 'when has a tie' do
      let(:plays) {
        [TrucoBot::Game::Play.new(player_one, card_2_cups),
        TrucoBot::Game::Play.new(player_two, card_2_cups)]
      }

      it 'return all plays' do
        expect(described_class.new(plays).call).to eq(plays.reverse)
      end
    end
  end
end
