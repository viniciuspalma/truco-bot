# frozen_string_literal: true

module TrucoBot
  module Game
    # A chain of Envido calls, such as Envido, Envido, Real Envido.
    #
    # Accepted, the chain is worth the sum of its calls, or the Falta when it
    # ends in Falta Envido. Declined, the caller earns what the chain was
    # worth before the last call, or 1 point if it was the first call.
    class EnvidoBet
      POINTS = { envido: 2, real_envido: 3 }.freeze
      MAX_ENVIDOS = 2

      attr_reader :calls, :caller

      def initialize(falta_points:)
        @falta_points = falta_points
        @calls = []
        @caller = nil
      end

      def next_calls
        case calls.last
        when :falta_envido then []
        when :real_envido then %i[falta_envido]
        else
          calls.count(:envido) < MAX_ENVIDOS ? Action::ENVIDO_CALLS : %i[real_envido falta_envido]
        end
      end

      def call(player, name)
        raise Error, "cannot call #{name} now" unless next_calls.include?(name)

        @calls << name
        @caller = player
      end

      def accepted_points = worth(calls)

      def declined_points = calls.one? ? 1 : worth(calls[...-1])

      private

      def worth(chain)
        chain.last == :falta_envido ? @falta_points.call : chain.sum { POINTS.fetch(it) }
      end
    end
  end
end
