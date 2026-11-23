# frozen_string_literal: true

module TrucoBot
  module Game
    # A shuffled 40-card Spanish deck.
    class Deck
      CARDS = Card::SUITS.product(Card::RANKS).map { |suit, rank| Card.new(rank:, suit:) }.freeze
      HAND_SIZE = 3

      def initialize(random: Random.new)
        @cards = CARDS.shuffle(random:)
      end

      def size = @cards.size

      def draw
        @cards.pop or raise Error, 'the deck is empty'
      end

      # Deals three cards to each player, one at a time, starting with the
      # first player given (the mano).
      def deal(players)
        hands = players.to_h { |player| [player, []] }
        HAND_SIZE.times { players.each { |player| hands[player] << draw } }
        hands.transform_values(&:freeze)
      end
    end
  end
end
