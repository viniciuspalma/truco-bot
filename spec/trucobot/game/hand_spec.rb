# frozen_string_literal: true

RSpec.describe TrucoBot::Game::Hand do
  subject(:hand) { build_hand(alice_cards, bob_cards) }

  let(:alice) { player('alice') } # mano: plays first
  let(:bob) { player('bob') }
  let(:scoreboard) { scoreboard_for([alice, bob]) }

  # Alice: Envido 31 (7 and 4 of clubs). Bob: Envido 25 (3 and 2 of golds).
  let(:alice_cards) { [card(1, :swords), card(7, :clubs), card(4, :clubs)] }
  let(:bob_cards) { [card(3, :golds), card(2, :golds), card(12, :cups)] }

  def build_hand(alice_cards, bob_cards, flor: false)
    described_class.new(
      players: [alice, bob], mano: alice, rules: rules(flor:), scoreboard:,
      cards: { alice => alice_cards, bob => bob_cards }
    )
  end

  def act(player, name, card = nil) = hand.act(player, action(name, card))

  def scores = [scoreboard[alice], scoreboard[bob]]

  describe 'turns' do
    it 'starts with the mano' do
      expect(hand.actor).to eq(alice)
    end

    it 'offers the player to move their cards, Truco, Envido and going to the deck' do
      expect(action_names(hand.allowed_actions(alice)))
        .to eq(%i[play_card truco envido real_envido falta_envido al_mazo])
      expect(hand.allowed_actions(alice).select(&:play_card?).map(&:card)).to match_array(alice_cards)
    end

    it 'offers nothing to the player who is not moving' do
      expect(hand.allowed_actions(bob)).to be_empty
    end

    it 'alternates within a trick' do
      act(alice, :play_card, card(4, :clubs))
      expect(hand.actor).to eq(bob)
    end

    it 'removes played cards from the hand' do
      act(alice, :play_card, card(4, :clubs))
      expect(hand.cards_of(alice)).to contain_exactly(card(1, :swords), card(7, :clubs))
    end

    it 'lets the winner of a trick lead the next one' do
      play_cards(hand, card(4, :clubs), card(12, :cups))
      expect(hand.actor).to eq(bob)
    end

    it 'refuses moves out of turn' do
      expect { act(bob, :play_card, card(3, :golds)) }.to raise_error(TrucoBot::IllegalAction)
    end

    it 'refuses cards the player does not hold' do
      expect { act(alice, :play_card, card(3, :golds)) }.to raise_error(TrucoBot::IllegalAction)
    end
  end

  describe 'winning the hand on tricks' do
    def outcome(*cards)
      play_cards(hand, *cards)
      [hand.finished?, hand.winner, hand.tricks.size]
    end

    context 'with ordinary cards' do
      let(:alice_cards) { [card(3, :cups), card(2, :cups), card(4, :golds)] }
      let(:bob_cards) { [card(12, :swords), card(1, :golds), card(3, :swords)] }

      it 'ends as soon as someone wins two tricks' do
        expect(outcome(card(3, :cups), card(12, :swords), card(2, :cups), card(1, :golds)))
          .to eq([true, alice, 2])
      end

      it 'goes to a third trick at one each' do
        expect(outcome(card(3, :cups), card(12, :swords), card(4, :golds), card(1, :golds), card(3, :swords),
                       card(2, :cups))).to eq([true, bob, 3])
      end

      it 'goes to whoever wins the first trick when the second ties' do
        expect(outcome(card(4, :golds), card(12, :swords), card(3, :swords), card(3, :cups)))
          .to eq([true, bob, 2])
      end

      it 'goes to whoever wins the first trick when the third ties at one each' do
        expect(outcome(card(2, :cups), card(12, :swords), card(4, :golds), card(1, :golds), card(3, :swords),
                       card(3, :cups))).to eq([true, alice, 3])
      end

      it 'scores the hand for the winner' do
        outcome(card(3, :cups), card(12, :swords), card(2, :cups), card(1, :golds))
        expect(scores).to eq([1, 0])
      end
    end

    context 'when the first trick ties' do
      let(:alice_cards) { [card(3, :cups), card(4, :golds), card(5, :cups)] }
      let(:bob_cards) { [card(3, :swords), card(6, :golds), card(5, :swords)] }

      it 'lets the mano lead the next trick' do
        play_cards(hand, card(3, :cups), card(3, :swords))
        expect(hand.actor).to eq(alice)
      end

      it 'goes to whoever wins the second trick' do
        expect(outcome(card(3, :cups), card(3, :swords), card(4, :golds), card(6, :golds)))
          .to eq([true, bob, 2])
      end

      it 'goes to the third trick when the second also ties' do
        expect(outcome(card(3, :cups), card(3, :swords), card(5, :cups), card(5, :swords), card(4, :golds),
                       card(6, :golds))).to eq([true, bob, 3])
      end
    end

    context 'when every trick ties' do
      let(:alice_cards) { [card(3, :cups), card(2, :cups), card(4, :golds)] }
      let(:bob_cards) { [card(3, :swords), card(2, :swords), card(4, :cups)] }

      it 'goes to the mano' do
        expect(outcome(card(3, :cups), card(3, :swords), card(2, :cups), card(2, :swords), card(4, :golds),
                       card(4, :cups))).to eq([true, alice, 3])
      end
    end
  end

  describe 'Truco' do
    it 'makes the hand worth 2 once accepted' do
      act(alice, :truco)
      act(bob, :quiero)
      expect(hand.truco_points).to eq(2)
    end

    it 'waits for an answer before play continues' do
      act(alice, :truco)
      expect(hand.actor).to eq(bob)
      expect(hand.pending_call).to eq(:truco)
      expect(action_names(hand.allowed_actions(bob)))
        .to eq(%i[quiero no_quiero retruco envido real_envido falta_envido])
    end

    it 'returns the turn to the caller once accepted' do
      act(alice, :truco)
      act(bob, :quiero)
      expect(hand.actor).to eq(alice)
    end

    it 'gives the caller 1 point and ends the hand when declined' do
      act(alice, :truco)
      act(bob, :no_quiero)
      expect([hand.finished?, hand.winner, scores]).to eq([true, alice, [1, 0]])
    end

    it 'can be raised in answer, and declining the raise pays the Truco' do
      act(alice, :truco)
      act(bob, :retruco)
      act(alice, :no_quiero)
      expect([hand.winner, scores]).to eq([bob, [0, 2]])
    end

    it 'climbs to Vale Cuatro and stops there' do
      act(alice, :truco)
      act(bob, :retruco)
      act(alice, :vale_cuatro)
      act(bob, :quiero)
      expect(hand.truco_points).to eq(4)
      expect(action_names(hand.allowed_actions(alice))).to eq(%i[play_card al_mazo])
    end

    it 'can be called by the second player after the first card' do
      act(alice, :play_card, card(4, :clubs))
      expect(action_names(hand.allowed_actions(bob))).to include(:truco)
    end

    it 'leaves the next raise to the player who accepted' do
      act(alice, :truco)
      act(bob, :quiero)
      expect(action_names(hand.allowed_actions(alice))).not_to include(:retruco)

      act(alice, :play_card, card(4, :clubs))
      expect(action_names(hand.allowed_actions(bob))).to include(:retruco)
    end

    it 'pays the accepted value to the hand winner' do
      act(alice, :truco)
      act(bob, :quiero)
      play_cards(hand, card(4, :clubs), card(12, :cups), card(3, :golds), card(7, :clubs))
      expect([hand.winner, scores]).to eq([bob, [0, 2]])
    end
  end

  describe 'Envido' do
    it 'pays 2 to the higher count when accepted' do
      act(alice, :envido)
      act(bob, :quiero)
      expect(scores).to eq([2, 0])
    end

    it 'goes to the mano on a tie' do
      tied = build_hand([card(5, :cups), card(2, :cups), card(1, :swords)],
                        [card(6, :golds), card(1, :golds), card(3, :clubs)])
      tied.act(alice, action(:play_card, card(1, :swords)))
      tied.act(bob, action(:envido))
      tied.act(alice, action(:quiero))
      expect(scores).to eq([2, 0])
    end

    it 'pays 1 to the caller when declined, and play goes on' do
      act(alice, :envido)
      act(bob, :no_quiero)
      expect([scores, hand.finished?, hand.actor]).to eq([[1, 0], false, alice])
    end

    it 'shows both counts when accepted' do
      events = []
      shown = described_class.new(players: [alice, bob], mano: alice, rules: rules, scoreboard:,
                                  cards: { alice => alice_cards, bob => bob_cards }, events:)
      shown.act(alice, action(:envido))
      shown.act(bob, action(:quiero))
      expect(events.find { it.type == :envido_shown }.details).to eq(scores: { alice => 31, bob => 25 })
    end

    it 'accepts raises and pays the whole chain' do
      act(alice, :envido)
      act(bob, :envido)
      act(alice, :real_envido)
      act(bob, :quiero)
      expect(scores).to eq([7, 0])
    end

    it 'pays the Falta to the winner' do
      scoreboard.add(bob, 18)
      act(alice, :falta_envido)
      act(bob, :quiero)
      expect(scores).to eq([12, 18])
    end

    it 'can only be called once per hand' do
      act(alice, :envido)
      act(bob, :no_quiero)
      expect(action_names(hand.allowed_actions(alice))).not_to include(:envido)
    end

    it 'is still open to the second player after the mano plays' do
      act(alice, :play_card, card(4, :clubs))
      expect(action_names(hand.allowed_actions(bob))).to include(:envido, :real_envido, :falta_envido)
    end

    it 'closes once a player has laid their first card' do
      play_cards(hand, card(4, :clubs), card(12, :cups))
      expect(action_names(hand.allowed_actions(bob))).not_to include(:envido)
    end

    it 'closes once a Truco is accepted' do
      act(alice, :truco)
      act(bob, :quiero)
      expect(action_names(hand.allowed_actions(alice))).not_to include(:envido)
    end

    it 'cannot answer a Retruco' do
      act(alice, :truco)
      act(bob, :retruco)
      expect(action_names(hand.allowed_actions(alice))).not_to include(:envido)
    end

    context 'when called over a Truco (el envido está primero)' do
      before do
        act(alice, :truco)
        act(bob, :envido)
      end

      it 'is answered first' do
        expect([hand.actor, hand.pending_call]).to eq([alice, :envido])
      end

      it 'hands the Truco back to its responder once settled' do
        act(alice, :quiero)
        expect([hand.actor, hand.pending_call]).to eq([bob, :truco])
        expect(action_names(hand.allowed_actions(bob))).to eq(%i[quiero no_quiero retruco])
      end

      it 'lets the Truco be declined afterwards' do
        act(alice, :quiero)
        act(bob, :no_quiero)
        expect([hand.winner, scores]).to eq([alice, [3, 0]])
      end
    end

    it 'ends the hand when its points win the match' do
      scoreboard.add(alice, 29)
      act(alice, :envido)
      act(bob, :no_quiero)
      expect([hand.finished?, scoreboard.winner]).to eq([true, alice])
    end
  end

  describe 'Flor' do
    subject(:hand) { build_hand(alice_cards, bob_cards, flor: true) }

    let(:alice_cards) { [card(7, :cups), card(6, :cups), card(1, :cups)] } # Flor 34

    it 'is not part of the game unless the rules allow it' do
      plain = build_hand(alice_cards, bob_cards)
      expect(action_names(plain.allowed_actions(alice))).to include(:envido).and exclude(:flor)
    end

    it 'replaces Envido for the player who holds it' do
      expect(action_names(hand.allowed_actions(alice))).to include(:flor).and exclude(:envido)
    end

    it 'scores 3 at once against a player without Flor' do
      act(alice, :flor)
      expect([scores, hand.pending_call, hand.actor]).to eq([[3, 0], nil, alice])
    end

    it 'shuts out Envido for the rest of the hand' do
      act(alice, :flor)
      act(alice, :play_card, card(1, :cups))
      expect(action_names(hand.allowed_actions(bob))).not_to include(:envido)
    end

    it 'cannot be sung after the first card' do
      act(alice, :play_card, card(1, :cups))
      act(bob, :play_card, card(12, :cups))
      expect(action_names(hand.allowed_actions(alice))).not_to include(:flor)
    end

    context 'when the opponent calls Envido' do
      subject(:hand) do
        build_hand([card(3, :golds), card(2, :cups), card(12, :swords)], alice_cards, flor: true)
      end

      it 'can be sung in answer, cancelling the Envido' do
        act(alice, :envido)
        expect(action_names(hand.allowed_actions(bob))).to include(:flor)

        act(bob, :flor)
        expect([scores, hand.pending_call, hand.actor]).to eq([[0, 3], nil, alice])
      end
    end

    context 'when both players hold Flor' do
      let(:bob_cards) { [card(5, :golds), card(4, :golds), card(10, :golds)] } # Flor 29

      before { act(alice, :flor) }

      it 'waits for the other Flor to answer' do
        expect([hand.actor, hand.pending_call]).to eq([bob, :flor])
        expect(action_names(hand.allowed_actions(bob)))
          .to eq(%i[contraflor contraflor_al_resto con_flor_me_achico])
      end

      it 'pays 6 to the best Flor on Contraflor' do
        act(bob, :contraflor)
        expect(scores).to eq([6, 0])
      end

      it 'pays the Falta to the best Flor on Contraflor al Resto' do
        act(bob, :contraflor_al_resto)
        expect(scoreboard.winner).to eq(alice)
        expect(hand).to be_finished
      end

      it 'pays 4 to the singer when the other backs down' do
        act(bob, :con_flor_me_achico)
        expect([scores, hand.actor]).to eq([[4, 0], alice])
      end
    end
  end

  describe 'going to the deck' do
    it 'gives the opponent what the hand is worth' do
      act(alice, :al_mazo)
      expect([hand.winner, scores]).to eq([bob, [0, 1]])
    end

    it 'pays an accepted Truco' do
      act(alice, :truco)
      act(bob, :quiero)
      act(alice, :al_mazo)
      expect(scores).to eq([0, 2])
    end
  end

  it 'offers nothing once finished' do
    act(alice, :al_mazo)
    expect([hand.actor, hand.allowed_actions(alice), hand.allowed_actions(bob)]).to eq([nil, [], []])
  end
end
