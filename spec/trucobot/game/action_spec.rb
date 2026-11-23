# frozen_string_literal: true

RSpec.describe TrucoBot::Game::Action do
  let(:seven) { card(7, :swords) }

  it 'builds a card play' do
    expect(described_class.play(seven)).to have_attributes(name: :play_card, card: seven, play_card?: true)
  end

  it 'rejects unknown names' do
    expect { described_class.new(name: :flee) }.to raise_error(ArgumentError, /unknown/)
  end

  it 'requires a card only for card plays' do
    expect { described_class.new(name: :play_card) }.to raise_error(ArgumentError, /needs a card/)
    expect { described_class.new(name: :truco, card: seven) }.to raise_error(ArgumentError, /does not take/)
  end

  describe '.coerce' do
    it 'returns actions unchanged' do
      original = described_class.new(name: :quiero)
      expect(described_class.coerce(original)).to be(original)
    end

    it 'builds an action from a name and an optional card' do
      expect(described_class.coerce('truco')).to eq(described_class.new(name: :truco))
      expect(described_class.coerce(:play_card, seven)).to eq(described_class.play(seven))
    end
  end

  it 'groups calls by kind' do
    expect(described_class.new(name: :retruco)).to be_truco_call
    expect(described_class.new(name: :real_envido)).to be_envido_call
    expect(described_class.new(name: :contraflor)).to be_flor_answer
  end

  it 'describes itself' do
    expect(described_class.play(seven).to_s).to eq('play 7 of swords')
    expect(described_class.new(name: :vale_cuatro).to_s).to eq('vale_cuatro')
  end
end
