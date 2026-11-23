# frozen_string_literal: true

module TrucoBot
  module Game
    # Points per player in a match. The match ends the moment someone reaches
    # the target, even in the middle of a hand.
    class Scoreboard
      attr_reader :target

      def initialize(players, target:)
        @target = target
        @points = players.to_h { [it, 0] }
      end

      def [](player) = @points.fetch(player)

      def to_h = @points.dup

      def add(player, points)
        @points[player] = [self[player] + points, target].min
      end

      def winner = @points.key(target)

      def finished? = !winner.nil?

      # Falta Envido is worth what the leader still needs to win the match.
      def falta_points = target - @points.values.max
    end
  end
end
