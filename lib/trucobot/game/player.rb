module TrucoBot
  module Game
    class Player
      attr_reader :hand

      def initialize(username)
        @username = username
        @hand = []
      end

      def receive_card(card)
        return unless @hand.size <3
        @hand.push(card)
      end

      def pick_card(card_position)
        return unless card_position <3
        @hand.push @hand.delete_at(card_position)
      end

      def use_card
        return if @hand.empty?
        @hand.pop
      end
    end
  end
end
