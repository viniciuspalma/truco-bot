# frozen_string_literal: true

module TrucoBot
  module Game
    Event = Data.define(:type, :player, :details)

    # A record of something that happened, for narrating the match (in Slack,
    # a log, a replay). `details` holds type-specific data.
    #
    # Types: :hand_started, :card_played, :trick_won, :trick_tied, :called,
    # :accepted, :declined, :envido_shown, :flor_shown, :folded, :points_awarded,
    # :hand_won, :match_won.
    class Event
      def initialize(type:, player: nil, details: {}) = super
    end
  end
end
