# frozen_string_literal: true

RSpec.describe TrucoBot::Game::Player do
  it 'uses the id as the name by default' do
    expect(described_class.new(id: 'U123').name).to eq('U123')
  end

  it 'compares by value' do
    vini = described_class.new(id: 'U1', name: 'Vini')
    expect(vini).to eq(described_class.new(id: 'U1', name: 'Vini'))
    expect(vini).not_to eq(described_class.new(id: 'U1'))
  end

  it 'prints its name' do
    expect(described_class.new(id: 'U1', name: 'Vini').to_s).to eq('Vini')
  end
end
