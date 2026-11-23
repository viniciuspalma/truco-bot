# frozen_string_literal: true

module TrucoBot
  module Game
    # One round of the hand: each player puts down one card.
    class Trick
      PLAYERS = 2

      attr_reader :plays

      def initialize
        @plays = []
      end

      def play(player, card)
        raise Error, 'trick is already complete' if complete?

        @plays << Play.new(player:, card:)
      end

      def played?(player) = plays.any? { it.player == player }

      def complete? = plays.size == PLAYERS

      def leader = plays.first&.player

      # The player with the stronger card, or nil when the cards tie (parda).
      def winner
        return unless complete?

        first, second = plays
        if first.card.beats?(second.card) then first.player
        elsif second.card.beats?(first.card) then second.player
        end
      end

      def tied? = complete? && winner.nil?
    end
  end
end
