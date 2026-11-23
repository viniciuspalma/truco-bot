# frozen_string_literal: true

RSpec.describe TrucoBot::Game::EnvidoBet do
  let(:alice) { player('alice') }
  let(:bob) { player('bob') }
  let(:falta) { 17 }

  def chain(*calls)
    described_class.new(falta_points: -> { falta }).tap do |bet|
      calls.each_with_index { |name, i| bet.call(i.even? ? alice : bob, name) }
    end
  end

  # [calls, points if accepted, points if declined]
  {
    %i[envido] => [2, 1],
    %i[real_envido] => [3, 1],
    %i[falta_envido] => [17, 1],
    %i[envido envido] => [4, 2],
    %i[envido real_envido] => [5, 2],
    %i[envido falta_envido] => [17, 2],
    %i[real_envido falta_envido] => [17, 3],
    %i[envido envido real_envido] => [7, 4],
    %i[envido envido falta_envido] => [17, 4],
    %i[envido real_envido falta_envido] => [17, 5],
    %i[envido envido real_envido falta_envido] => [17, 7]
  }.each do |calls, (accepted, declined)|
    context "with #{calls.join(', ')}" do
      subject(:bet) { chain(*calls) }

      it("is worth #{accepted} when accepted") { expect(bet.accepted_points).to eq(accepted) }
      it("is worth #{declined} when declined") { expect(bet.declined_points).to eq(declined) }
    end
  end

  describe '#next_calls' do
    it 'opens with any Envido call' do
      expect(chain.next_calls).to eq(%i[envido real_envido falta_envido])
    end

    it 'allows a second Envido but not a third' do
      expect(chain(:envido).next_calls).to include(:envido)
      expect(chain(:envido, :envido).next_calls).to eq(%i[real_envido falta_envido])
    end

    it 'allows only Falta Envido after Real Envido' do
      expect(chain(:real_envido).next_calls).to eq(%i[falta_envido])
    end

    it 'ends with Falta Envido' do
      expect(chain(:falta_envido).next_calls).to be_empty
    end
  end

  it 'refuses calls out of order' do
    expect { chain(:real_envido, :envido) }.to raise_error(TrucoBot::Error)
  end

  it 'remembers the last caller' do
    expect(chain(:envido, :real_envido).caller).to eq(bob)
  end
end
