# frozen_string_literal: true

module TrucoBot
  module Game
    Player = Data.define(:id, :name)

    # Who is playing. `id` is whatever identifies them to the caller, such as
    # a Slack user id; the engine only compares players for equality.
    class Player
      def initialize(id:, name: id.to_s) = super

      def to_s = name
    end
  end
end
