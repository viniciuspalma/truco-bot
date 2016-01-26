module TrucoBot
  module Game
    class Deck
      attr_accessor :cards

      def initialize
        @cards = []
        build_deck
      end

      private
      def build_deck
        suits = TrucoBot::Game::Card::SUITS
        ranks = TrucoBot::Game::Card::RANKS

        suits.each do |suit|
          ranks.each do |rank|
            @cards.push TrucoBot::Game::Card.new(rank, suit)
          end
        end
      end
    end
  end
end
