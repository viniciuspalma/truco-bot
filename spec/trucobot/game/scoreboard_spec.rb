# frozen_string_literal: true

RSpec.describe TrucoBot::Game::Scoreboard do
  subject(:scoreboard) { described_class.new([alice, bob], target: 30) }

  let(:alice) { player('alice') }
  let(:bob) { player('bob') }

  it 'starts everyone at zero' do
    expect(scoreboard.to_h).to eq(alice => 0, bob => 0)
  end

  it 'adds points' do
    scoreboard.add(alice, 3)
    scoreboard.add(alice, 2)
    expect(scoreboard[alice]).to eq(5)
  end

  it 'caps scores at the target and declares the winner' do
    scoreboard.add(bob, 28)
    scoreboard.add(bob, 4)
    expect(scoreboard).to have_attributes(winner: bob, finished?: true)
    expect(scoreboard[bob]).to eq(30)
  end

  it 'has no winner before the target' do
    scoreboard.add(alice, 29)
    expect(scoreboard).to have_attributes(winner: nil, finished?: false)
  end

  it 'prices the Falta as what the leader still needs' do
    scoreboard.add(alice, 12)
    scoreboard.add(bob, 20)
    expect(scoreboard.falta_points).to eq(10)
  end
end
