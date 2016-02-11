module TrucoBot
  module Game
    class Round
      def initialize(plays=[])
        @plays = plays
      end

      def winner
        EvaluateRound.new(@plays).call
      end
    end
  end
end
