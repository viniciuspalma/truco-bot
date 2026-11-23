# frozen_string_literal: true

module TrucoBot
  module Game
    Rules = Data.define(:target_score, :flor)

    # Table rules agreed before the match starts.
    class Rules
      def initialize(target_score: 30, flor: false)
        unless target_score.is_a?(Integer) && target_score.positive?
          raise ArgumentError, "target_score must be a positive integer, got #{target_score.inspect}"
        end

        super
      end

      alias flor? flor
    end
  end
end
