module TrucoBot
  module Game
    class Round
      def initialize(plays=[])
        @plays = plays
      end

      def winner
        EvaluateRound.call @plays
      end
    end
  end
end
