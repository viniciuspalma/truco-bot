module TrucoBot
  module Game
    class Card
      SUITS = %i(clubs golds cups swords)
      RANKS = %i(4 5 6 7 10 11 12 1 2 3)

      attr_reader :rank
      attr_reader :suit

      def initialize(rank, suit)
        @rank = rank
        @suit = suit
      end

      def to_sym
        "#{@rank}_#{@suit}".to_sym
      end

      def is_club?
        @suit == :clubs
      end

      def is_gold?
        @suit == :golds
      end

      def is_cup?
        @suit == :cups
      end

      def is_sword?
        @suit == :swords
      end

      def <=>(card)
        RANKS.find_index(self.rank) <=> RANKS.find_index(card.rank)
      end
    end
  end
end
