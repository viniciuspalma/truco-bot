# frozen_string_literal: true

RSpec.describe TrucoBot::Game::Match do
  subject(:match) { described_class.new(players: [alice, bob], deal:) }

  let(:alice) { player('alice') }
  let(:bob) { player('bob') }
  let(:deals) { [] }
  # Each hand gets the same cards: the mano holds the 1 of swords, 7 and 4 of
  # clubs (Envido 31), the dealer the 3 and 2 of golds and the 12 of cups.
  let(:deal) do
    lambda do |(mano, dealer)|
      deals << [mano, dealer]
      {
        mano => [card(1, :swords), card(7, :clubs), card(4, :clubs)],
        dealer => [card(3, :golds), card(2, :golds), card(12, :cups)]
      }
    end
  end

  def concede_hand = match.act(match.actor, :al_mazo)

  describe '.new' do
    it 'needs two different players' do
      expect { described_class.new(players: [alice]) }.to raise_error(ArgumentError)
      expect { described_class.new(players: [alice, alice]) }.to raise_error(ArgumentError)
    end

    it 'needs the dealer to be playing' do
      expect { described_class.new(players: [alice, bob], dealer: player('carol')) }.to raise_error(ArgumentError)
    end

    it 'deals from a shuffled deck by default' do
      dealt = described_class.new(players: [alice, bob], random: Random.new(7))
      expect(dealt.hand.cards_of(alice).size + dealt.hand.cards_of(bob).size).to eq(6)
    end
  end

  it 'starts the first hand with the first player as mano' do
    expect([match.hand_number, match.dealer, match.mano, match.actor]).to eq([1, bob, alice, alice])
  end

  it 'deals to the mano first' do
    match
    expect(deals).to eq([[alice, bob]])
  end

  it 'passes the deal after every hand' do
    concede_hand
    expect([match.hand_number, match.dealer, match.mano, match.actor]).to eq([2, alice, bob, bob])
    expect(deals.last).to eq([bob, alice])
  end

  it 'carries the score across hands' do
    concede_hand # alice folds: bob +1
    concede_hand # bob folds: alice +1
    match.act(alice, :truco)
    match.act(bob, :no_quiero) # alice +1
    expect([match.score(alice), match.score(bob)]).to eq([2, 1])
  end

  it 'accepts actions as names or Action objects' do
    match.act(alice, :play_card, card(4, :clubs))
    match.act(bob, action(:play_card, card(12, :cups)))
    expect(match.hand.tricks.first.winner).to eq(bob)
  end

  it 'rejects illegal actions' do
    expect { match.act(bob, :truco) }.to raise_error(TrucoBot::IllegalAction)
  end

  context 'when someone reaches the target score' do
    subject(:match) { described_class.new(players: [alice, bob], rules: rules(target_score: 3), deal:) }

    before do
      match.act(alice, :envido)
      match.act(bob, :real_envido)
      match.act(alice, :no_quiero) # bob +2
      concede_hand # alice folds: bob +1 = 3
    end

    it 'is over' do
      expect([match.finished?, match.winner, match.actor]).to eq([true, bob, nil])
    end

    it 'offers no more actions' do
      expect([match.allowed_actions(alice), match.allowed_actions(bob)]).to eq([[], []])
      expect { match.act(alice, :al_mazo) }.to raise_error(TrucoBot::IllegalAction, /over/)
    end

    it 'announces the winner' do
      expect(match.events.last).to have_attributes(type: :match_won, player: bob)
    end

    it 'does not deal another hand' do
      expect(match.hand_number).to eq(1)
    end
  end

  it 'can end in the middle of a hand on Envido points' do
    short = described_class.new(players: [alice, bob], rules: rules(target_score: 2), deal:)
    short.act(alice, :envido)
    short.act(bob, :quiero)
    expect([short.finished?, short.winner, short.hand.tricks.first.plays]).to eq([true, alice, []])
  end

  describe '#view' do
    subject(:view) { match.view(bob) }

    before { match.act(alice, :play_card, card(4, :clubs)) }

    it "shows the player's own cards only" do
      expect(view.cards).to contain_exactly(card(3, :golds), card(2, :golds), card(12, :cups))
    end

    it 'shows the table, the score and what to do' do
      expect(view).to have_attributes(
        player: bob, opponent: alice, hand_number: 1, mano: alice,
        scores: { alice => 0, bob => 0 }, target_score: 30, truco_points: 1,
        pending_call: nil, actor: bob, my_turn?: true
      )
      expect(view.tricks).to eq([[TrucoBot::Game::Play.new(player: alice, card: card(4, :clubs))]])
      expect(view.allowed_actions).to eq(match.allowed_actions(bob))
    end

    it 'tells the waiting player it is not their turn' do
      expect(match.view(alice)).to have_attributes(my_turn?: false, allowed_actions: [])
    end
  end

  it 'keeps its state when dealing the next hand fails' do
    failing = described_class.new(players: [alice, bob], deal: lambda { |order|
      raise 'deck jammed' if deals.size == 1

      deal.call(order)
    })
    expect { failing.act(alice, :al_mazo) }.to raise_error(RuntimeError, 'deck jammed')
    expect([failing.hand_number, failing.dealer]).to eq([1, bob])
  end

  describe 'events' do
    it 'keeps event details read-only' do
      match.act(alice, :truco)
      match.act(bob, :no_quiero)
      expect(match.events.map(&:details)).to all(be_frozen)
    end

    it 'narrates the match' do
      match.act(alice, :truco)
      match.act(bob, :no_quiero)
      expect(match.events.map(&:type))
        .to eq(%i[hand_started called declined hand_won points_awarded hand_started])
    end
  end

  # Plays random legal moves from many seeds to check that every match ends
  # and that exactly one player can move at any time.
  describe 'random play' do
    # Far more moves than any real match to 30 needs.
    let(:move_budget) { 2_000 }

    it 'always reaches a winner', :aggregate_failures do
      40.times do |seed|
        random = Random.new(seed)
        game = described_class.new(players: [alice, bob], random:, rules: rules(flor: seed.odd?))

        moves = 0
        until game.finished?
          moves += 1
          raise "seed #{seed} did not finish within #{move_budget} moves" if moves > move_budget

          mover = game.actor
          expect(game.allowed_actions(game.opponent(mover))).to be_empty
          game.act(mover, game.allowed_actions(mover).sample(random:))
        end

        expect(game.score(game.winner)).to eq(30)
      end
    end
  end
end
