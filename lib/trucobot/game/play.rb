module TrucoBot
  module Game
    class Play
      attr_reader :player
      attr_reader :card

      def initialize(player, card)
        @player = player
        @card = card
      end

      def <=>(play)
        self.card <=> play.card
      end
    end
  end
end
