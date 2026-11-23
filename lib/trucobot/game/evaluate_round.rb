module TrucoBot
  module Game
    class EvaluateRound
      def initialize(plays)
        @plays = plays
      end

      def call
        return winner_with_high_cards if high_cards?
        winner_without_high_cards
      end

      def winner_with_high_cards
        return highest_cards if highest_cards.size == 1

        @plays.sort.reverse.chunk_while { |play_1, play_2|
          (play_1.compare_high_cards(play_2)) == 0
        }.first
      end

      def winner_without_high_cards
        @plays.sort.reverse.chunk_while { |play_1, play_2|
          (play_1 <=> play_2) == 0
        }.first
      end

      def highest_cards
        @plays.map { |play|
          play if Card::HIGH_CARDS.include?(play.card.to_sym)
        }.compact
      end

      def high_cards?
        highest_cards.any?
      end
    end
  end
end
