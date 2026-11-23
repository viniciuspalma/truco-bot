# frozen_string_literal: true

RSpec.describe TrucoBot::Game::TrucoBet do
  subject(:bet) { described_class.new }

  let(:alice) { player('alice') }
  let(:bob) { player('bob') }

  it 'is worth 1 point before anything is called' do
    expect(bet).to have_attributes(points: 1, pending?: false, next_call: :truco)
  end

  it 'lets anyone open with Truco' do
    expect([bet.can_call?(alice), bet.can_call?(bob)]).to eq([true, true])
  end

  it 'keeps the previous value while a call is pending' do
    bet.call(alice)
    expect(bet).to have_attributes(points: 1, pending?: true, caller: alice, opening_call_pending?: true)
  end

  it 'climbs to 2, 3 and 4 points as calls are accepted' do
    points = %i[truco retruco vale_cuatro].each_with_index.map do |_, i|
      caller, accepter = i.even? ? [alice, bob] : [bob, alice]
      bet.call(caller)
      bet.accept(accepter)
      bet.points
    end

    expect(points).to eq([2, 3, 4])
    expect(bet.next_call).to be_nil
  end

  it 'gives the right to raise to whoever accepted' do
    bet.call(alice)
    bet.accept(bob)
    expect([bet.can_call?(alice), bet.can_call?(bob)]).to eq([false, true])
  end

  it 'accepts the pending call when raising over it' do
    bet.call(alice)
    bet.call(bob)
    expect(bet).to have_attributes(points: 2, pending?: true, caller: bob, next_call: :vale_cuatro)
  end
end
