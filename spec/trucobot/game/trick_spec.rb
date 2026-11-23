# frozen_string_literal: true

RSpec.describe TrucoBot::Game::Trick do
  subject(:trick) { described_class.new }

  let(:alice) { player('alice') }
  let(:bob) { player('bob') }

  it 'has no winner until both players play' do
    trick.play(alice, card(1, :swords))
    expect(trick).to have_attributes(complete?: false, winner: nil, tied?: false, leader: alice)
  end

  it 'goes to the stronger card' do
    trick.play(alice, card(4, :cups))
    trick.play(bob, card(5, :cups))
    expect(trick.winner).to eq(bob)
  end

  # Regression: the stronger of two top cards with the same number used to
  # lose whenever it was played first.
  [
    [[7, :swords], [7, :golds]],
    [[1, :swords], [1, :clubs]]
  ].each do |(strong, weak)|
    it "gives #{strong.join(' of ')} the trick over #{weak.join(' of ')} in either order" do
      first = described_class.new
      first.play(alice, card(*strong))
      first.play(bob, card(*weak))

      second = described_class.new
      second.play(bob, card(*weak))
      second.play(alice, card(*strong))

      expect([first.winner, second.winner]).to eq([alice, alice])
    end
  end

  it 'ties (parda) on cards of equal strength' do
    trick.play(alice, card(3, :cups))
    trick.play(bob, card(3, :swords))
    expect(trick).to have_attributes(winner: nil, tied?: true)
  end

  it 'remembers who played' do
    trick.play(alice, card(3, :cups))
    expect([trick.played?(alice), trick.played?(bob)]).to eq([true, false])
  end

  it 'refuses a third card' do
    trick.play(alice, card(3, :cups))
    trick.play(bob, card(3, :swords))
    expect { trick.play(alice, card(4, :cups)) }.to raise_error(TrucoBot::Error)
  end
end
