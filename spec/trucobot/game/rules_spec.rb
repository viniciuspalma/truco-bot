# frozen_string_literal: true

RSpec.describe TrucoBot::Game::Rules do
  it 'plays to 30 without Flor by default' do
    expect(described_class.new).to have_attributes(target_score: 30, flor?: false)
  end

  it 'accepts shorter matches and Flor' do
    expect(described_class.new(target_score: 15, flor: true)).to have_attributes(target_score: 15, flor?: true)
  end

  it 'rejects a target score that is not a positive integer' do
    expect { described_class.new(target_score: 0) }.to raise_error(ArgumentError)
    expect { described_class.new(target_score: '30') }.to raise_error(ArgumentError)
  end
end
