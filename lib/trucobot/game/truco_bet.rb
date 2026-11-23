# frozen_string_literal: true

module TrucoBot
  module Game
    # The Truco ladder: what the hand is worth and who may raise it.
    #
    # The hand is worth 1 point until a Truco is accepted, then 2 (Truco),
    # 3 (Retruco) or 4 (Vale Cuatro). Turning a call down hands the caller
    # the value already accepted. Only the player who accepted the last call
    # may raise again.
    class TrucoBet
      CALLS = Action::TRUCO_CALLS
      POINTS = [1, 2, 3, 4].freeze

      attr_reader :caller

      def initialize
        @called = 0
        @accepted = 0
        @caller = nil
        @holder = nil
      end

      def pending? = @called > @accepted

      def accepted? = @accepted.positive?

      # True while only the opening Truco has been called and nobody answered.
      def opening_call_pending? = pending? && @called == 1

      def points = POINTS.fetch(@accepted)

      def next_call = CALLS[@called]

      def can_call?(player)
        !pending? && !next_call.nil? && (@holder.nil? || @holder == player)
      end

      # Raising in answer to a pending call accepts it first ("quiero retruco").
      def call(player)
        accept(nil) if pending?
        @called += 1
        @caller = player
      end

      def accept(player)
        @accepted = @called
        @holder = player
      end
    end
  end
end
