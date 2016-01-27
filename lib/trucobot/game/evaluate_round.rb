module TrucoBot
  module Game
    class EvaluateRound
      def self.call(plays)
        new.call(plays)
      end

      def call(plays)
        plays.sort.reverse.chunk_while { |play_1, play_2|
          (play_1 <=> play_2) == 0
        }
      end
    end
  end
end
