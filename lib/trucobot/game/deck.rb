module TrucoBot
  module Game
    class Deck
      attr_reader :cards

      def initialize
        @cards = build_deck
      end

      def hand_out
        @cards.shuffle!.pop
      end

      private
      def build_deck
        suits = Card::SUITS
        ranks = Card::RANKS

        suits.product(ranks).map { |suit, rank| Card.new(rank, suit) }
      end
    end
  end
end
