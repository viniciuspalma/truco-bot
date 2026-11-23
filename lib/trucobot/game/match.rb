# frozen_string_literal: true

module TrucoBot
  module Game
    # A 1v1 match played over as many hands as it takes to reach the target
    # score. The deal passes to the other player after every hand, and the
    # player who did not deal is the mano.
    #
    #   match = Match.new(players: [alice, bob])
    #   match.actor                    # => alice
    #   match.allowed_actions(alice)   # => [#<data Action name=:play_card, ...>, ...]
    #   match.act(alice, :truco)
    #   match.act(bob, :quiero)
    #   match.act(alice, :play_card, card)
    class Match
      PLAYERS = 2

      attr_reader :players, :rules, :scoreboard, :events, :dealer, :hand_number, :hand

      # `deal` builds each hand: it receives the players, mano first, and
      # returns a Hash of Player => [Card, Card, Card]. It defaults to a
      # freshly shuffled deck; pass one in for tests or replays.
      def initialize(players:, rules: Rules.new, random: Random.new, dealer: players.last, deal: nil)
        unless players.size == PLAYERS && players.uniq.size == PLAYERS
          raise ArgumentError, 'a match needs exactly two different players'
        end
        raise ArgumentError, 'the dealer must be one of the players' unless players.include?(dealer)

        @players = players.dup.freeze
        @rules = rules
        @deal = deal || ->(order) { Deck.new(random:).deal(order) }
        @scoreboard = Scoreboard.new(@players, target: rules.target_score)
        @events = []
        @dealer = dealer
        @hand_number = 0
        start_hand
      end

      def finished? = scoreboard.finished?

      def winner = scoreboard.winner

      def score(player) = scoreboard[player]

      def mano = hand.mano

      # The player who must move next, or nil once the match is over.
      def actor = finished? ? nil : hand.actor

      def allowed_actions(player) = finished? ? [] : hand.allowed_actions(player)

      def act(player, action, card = nil)
        raise IllegalAction, 'the match is over' if finished?

        hand.act(player, Action.coerce(action, card))
        after_action
        self
      end

      def view(player)
        PlayerView.new(
          player:, opponent: opponent(player),
          cards: hand.cards_of(player), tricks: hand.tricks.map { it.plays.dup },
          scores: scoreboard.to_h, target_score: scoreboard.target,
          hand_number:, mano:, truco_points: hand.truco_points, pending_call: hand.pending_call,
          actor:, allowed_actions: allowed_actions(player)
        )
      end

      def opponent(player) = players.find { it != player }

      private

      def after_action
        if finished?
          record(:match_won, winner, scores: scoreboard.to_h)
        elsif hand.finished?
          @dealer = opponent(dealer)
          start_hand
        end
      end

      def start_hand
        @hand_number += 1
        mano = opponent(dealer)
        order = [mano, dealer]
        @hand = Hand.new(
          players: order, mano:, cards: @deal.call(order),
          rules:, scoreboard:, events:
        )
        record(:hand_started, mano, number: hand_number, dealer:)
      end

      def record(type, player, **details)
        events << Event.new(type:, player:, details:)
      end
    end
  end
end
