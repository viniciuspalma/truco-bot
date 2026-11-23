# frozen_string_literal: true

module TrucoBot
  module Game
    # Envido and Flor counts for a dealt hand of three cards.
    module Scoring
      SAME_SUIT_BONUS = 20

      module_function

      # Two cards of the same suit score 20 plus their values; otherwise the
      # hand is worth its single highest card. Face cards count zero.
      def envido(cards)
        same_suit = cards.group_by(&:suit).values.select { it.size >= 2 }
        best_pair = same_suit.map { |suited| SAME_SUIT_BONUS + suited.map(&:envido_value).max(2).sum }.max

        best_pair || cards.map(&:envido_value).max
      end

      def flor?(cards) = cards.size == Deck::HAND_SIZE && cards.map(&:suit).uniq.one?

      def flor(cards) = SAME_SUIT_BONUS + cards.sum(&:envido_value)
    end
  end
end
