# frozen_string_literal: true

module TrucoBot
  module Game
    Card = Data.define(:rank, :suit)

    # A card from the 40-card Spanish deck (no 8s, 9s or jokers).
    class Card
      SUITS = %i[swords clubs golds cups].freeze
      RANKS = [1, 2, 3, 4, 5, 6, 7, 10, 11, 12].freeze

      # The four "matas" outrank everything, in this order.
      TOP_CARDS = {
        [1, :swords] => 14,
        [1, :clubs] => 13,
        [7, :swords] => 12,
        [7, :golds] => 11
      }.freeze

      # Every other card is ranked by number alone, regardless of suit.
      STRENGTH_BY_RANK = {
        3 => 10, 2 => 9, 1 => 8, 12 => 7, 11 => 6,
        10 => 5, 7 => 4, 6 => 3, 5 => 2, 4 => 1
      }.freeze

      def initialize(rank:, suit:)
        raise ArgumentError, "invalid rank: #{rank.inspect}" unless RANKS.include?(rank)
        raise ArgumentError, "invalid suit: #{suit.inspect}" unless SUITS.include?(suit)

        super
      end

      # Trick-taking strength, from 1 (any 4) to 14 (1 of swords).
      # Two cards of equal strength tie the trick ("parda").
      def strength
        TOP_CARDS.fetch([rank, suit]) { STRENGTH_BY_RANK.fetch(rank) }
      end

      def beats?(other) = strength > other.strength

      # Value when counting Envido or Flor: face cards (10, 11, 12) count zero.
      def envido_value = figure? ? 0 : rank

      def figure? = rank >= 10

      def to_s = "#{rank} of #{suit}"
    end
  end
end
