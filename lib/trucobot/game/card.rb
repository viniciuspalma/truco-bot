module TrucoBot
  module Game
    class Card
      SUITS = %i(clubs golds cups swords)
      RANKS = %i(4 5 6 7 10 11 12 1 2 3)
      HIGH_CARDS = %i(1_swords 1_clubs 7_swords 7_golds)

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

      def compare_high_cards(card)
        high_cards_index(self.to_sym) <=> high_cards_index(card.to_sym)
      end

      def <=>(card)
        rank_index(self.rank) <=> rank_index(card.rank)
      end

      protected
      def rank_index(rank)
        RANKS.find_index rank
      end

      def high_cards_index(rank)
        HIGH_CARDS.find_index rank
      end
    end
  end
end
