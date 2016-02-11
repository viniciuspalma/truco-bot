module TrucoBot
  module Game
    class Play
      attr_reader :player
      attr_reader :card

      def initialize(player, card)
        @player = player
        @card = card
      end

      def compare_high_cards(play)
        self.card.compare_high_cards(play.card)
      end

      def <=>(play)
        self.card <=> play.card
      end
    end
  end
end
