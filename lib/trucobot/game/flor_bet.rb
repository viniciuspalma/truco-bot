# frozen_string_literal: true

module TrucoBot
  module Game
    # A Flor sung against an opponent who also holds Flor, waiting for their
    # answer. (Against an opponent without Flor it simply scores 3.)
    class FlorBet
      UNCONTESTED_POINTS = 3
      CONTRAFLOR_POINTS = 6
      ACHICO_POINTS = 4

      attr_reader :singer, :responder

      def initialize(singer:, responder:)
        @singer = singer
        @responder = responder
      end
    end
  end
end
