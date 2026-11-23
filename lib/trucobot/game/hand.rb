# frozen_string_literal: true

module TrucoBot
  module Game
    # One deal: up to three tricks plus whatever Truco, Envido and Flor are
    # called along the way. A Hand is a state machine: #actor says who must
    # move, #allowed_actions lists their legal moves and #act applies one.
    #
    # Pending calls are answered in priority order: Envido goes first ("el
    # envido está primero") and can be called on top of an unanswered opening
    # Truco, which waits until the Envido is settled.
    class Hand # rubocop:disable Metrics/ClassLength -- the state machine is easier to follow in one place
      MAX_TRICKS = 3
      TRICKS_TO_WIN = 2

      attr_reader :players, :mano, :tricks, :winner

      def initialize(players:, mano:, cards:, rules:, scoreboard:, events: [])
        @players = players
        @mano = mano
        @dealt = cards.transform_values { it.dup.freeze }.freeze
        @cards = cards.transform_values(&:dup)
        @rules = rules
        @scoreboard = scoreboard
        @events = events

        @tricks = [Trick.new]
        @turn = mano
        @truco = TrucoBet.new
        @envido = nil
        @envido_settled = false
        @flor = nil
        @flor_settled = false
        @finished = false
      end

      def finished? = @finished

      # Cards still in the player's hand.
      def cards_of(player) = @cards.fetch(player).dup

      def dealt_cards_of(player) = @dealt.fetch(player)

      # Points the hand is currently worth to whoever wins it.
      def truco_points = @truco.points

      # The call waiting for an answer, if any: :envido, :flor or :truco.
      def pending_call
        if @envido then :envido
        elsif @flor then :flor
        elsif @truco.pending? then :truco
        end
      end

      def actor
        return if finished?

        case pending_call
        when :envido then opponent(@envido.caller)
        when :flor then @flor.responder
        when :truco then opponent(@truco.caller)
        else @turn
        end
      end

      def allowed_actions(player)
        return [] unless player == actor

        case pending_call
        when :envido then envido_answers(player)
        when :flor then flor_answers
        when :truco then truco_answers(player)
        else turn_actions(player)
        end
      end

      def act(player, action)
        raise IllegalAction, "#{player} cannot #{action} now" unless allowed_actions(player).include?(action)

        apply(player, action)
        self
      end

      def opponent(player) = players.find { it != player }

      private

      # -- What each player may do -------------------------------------------

      def turn_actions(player)
        actions = cards_of(player).map { Action.play(it) }
        actions << action(@truco.next_call) if @truco.can_call?(player)
        actions.concat(envido_openers(player))
        actions << action(:flor) if can_sing_flor?(player)
        actions << action(:al_mazo)
      end

      def truco_answers(player)
        actions = answers
        actions << action(@truco.next_call) if @truco.next_call
        if @truco.opening_call_pending?
          actions.concat(envido_openers(player))
          actions << action(:flor) if can_sing_flor?(player)
        end
        actions
      end

      def envido_answers(player)
        actions = answers + @envido.next_calls.map { action(it) }
        actions << action(:flor) if can_sing_flor?(player)
        actions
      end

      def flor_answers = Action::FLOR_ANSWERS.map { action(it) }

      def answers = Action::ANSWERS.map { action(it) }

      def envido_openers(player)
        return [] unless envido_open?(player)

        Action::ENVIDO_CALLS.map { action(it) }
      end

      # Envido belongs to the first trick, before the player lays a card and
      # before any Truco is accepted. Someone holding Flor must sing it
      # instead.
      def envido_open?(player)
        !@envido_settled && @envido.nil? && @flor.nil? && !@truco.accepted? &&
          before_first_card?(player) && !(@rules.flor? && flor?(player))
      end

      def can_sing_flor?(player)
        @rules.flor? && flor?(player) && !@flor_settled && @flor.nil? && before_first_card?(player)
      end

      def before_first_card?(player) = tricks.one? && !current_trick.played?(player)

      def flor?(player) = Scoring.flor?(dealt_cards_of(player))

      def action(name) = Action.new(name:)

      # -- Applying actions --------------------------------------------------

      def apply(player, action) # rubocop:disable Metrics/CyclomaticComplexity
        case action.name
        when :play_card then play_card(player, action.card)
        when *Action::TRUCO_CALLS then call_truco(player, action.name)
        when *Action::ENVIDO_CALLS then call_envido(player, action.name)
        when :flor then sing_flor(player)
        when *Action::FLOR_ANSWERS then answer_flor(player, action.name)
        when :quiero then accept(player)
        when :no_quiero then decline(player)
        when :al_mazo then fold(player)
        end
      end

      def play_card(player, card)
        @cards.fetch(player).delete(card)
        current_trick.play(player, card)
        record(:card_played, player, card:)

        current_trick.complete? ? finish_trick : @turn = opponent(player)
      end

      def call_truco(player, name)
        @truco.call(player)
        record(:called, player, call: name)
      end

      def call_envido(player, name)
        @envido ||= EnvidoBet.new(falta_points: -> { @scoreboard.falta_points })
        @envido.call(player, name)
        record(:called, player, call: name)
      end

      def accept(player)
        record(:accepted, player, call: pending_call)
        pending_call == :envido ? show_envido : @truco.accept(player)
      end

      def decline(player)
        call = pending_call
        record(:declined, player, call:)

        if call == :envido
          caller = @envido.caller
          points = @envido.declined_points
          settle_envido
          award(caller, points, :envido)
        else
          award_hand(@truco.caller)
        end
      end

      def show_envido
        scores = players.to_h { [it, Scoring.envido(dealt_cards_of(it))] }
        record(:envido_shown, nil, scores:)
        points = @envido.accepted_points
        settle_envido
        award(best_of(scores), points, :envido)
      end

      def settle_envido
        @envido = nil
        @envido_settled = true
      end

      # Singing Flor wipes out any Envido: there is no Envido in a hand with
      # Flor.
      def sing_flor(player)
        record(:called, player, call: :flor)
        @envido = nil
        @envido_settled = true

        rival = opponent(player)
        if flor?(rival)
          @flor = FlorBet.new(singer: player, responder: rival)
        else
          settle_flor
          award(player, FlorBet::UNCONTESTED_POINTS, :flor)
        end
      end

      def answer_flor(player, answer)
        record(:called, player, call: answer)
        singer = @flor.singer
        settle_flor
        return award(singer, FlorBet::ACHICO_POINTS, :flor) if answer == :con_flor_me_achico

        scores = players.to_h { [it, Scoring.flor(dealt_cards_of(it))] }
        record(:flor_shown, nil, scores:)
        points = answer == :contraflor ? FlorBet::CONTRAFLOR_POINTS : @scoreboard.falta_points
        award(best_of(scores), points, :flor)
      end

      def settle_flor
        @flor = nil
        @flor_settled = true
      end

      def fold(player)
        record(:folded, player)
        award_hand(opponent(player))
      end

      # -- Tricks and the end of the hand ------------------------------------

      def current_trick = tricks.last

      def finish_trick
        trick = current_trick
        if trick.winner
          record(:trick_won, trick.winner, number: tricks.size)
        else
          record(:trick_tied, nil, number: tricks.size)
        end

        if (hand_winner = decided_by_tricks)
          award_hand(hand_winner)
        else
          @tricks << Trick.new
          @turn = trick.winner || mano
        end
      end

      # Two tricks win the hand. After a tie, the first trick that someone
      # won decides it; if every trick ties, the mano wins.
      def decided_by_tricks
        results = tricks.map(&:winner)
        decided = results.compact

        decided.tally.key(TRICKS_TO_WIN) ||
          (decided.first if results.include?(nil) && decided.any?) ||
          (mano if results.size == MAX_TRICKS)
      end

      # Ties in Envido and Flor go to the mano.
      def best_of(scores)
        best = scores.values.max
        scores[mano] == best ? mano : scores.key(best)
      end

      def award_hand(player)
        record(:hand_won, player)
        finish(player)
        award(player, @truco.points, :truco)
      end

      # Reaching the target score ends the hand on the spot, even mid-trick.
      def award(player, points, reason)
        @scoreboard.add(player, points)
        record(:points_awarded, player, points:, reason:)
        finish(nil) if @scoreboard.finished? && !finished?
      end

      def finish(winner)
        @winner = winner
        @finished = true
      end

      def record(type, player, **details)
        @events << Event.new(type:, player:, details:)
      end
    end
  end
end
