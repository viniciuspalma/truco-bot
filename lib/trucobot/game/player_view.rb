# frozen_string_literal: true

module TrucoBot
  module Game
    # Everything one player is allowed to know about the match right now:
    # their own cards but never the opponent's. Meant for rendering a Slack
    # message or feeding an AI.
    PlayerView = Data.define(
      :player, :opponent, :cards, :tricks, :scores, :target_score,
      :hand_number, :mano, :truco_points, :pending_call, :actor, :allowed_actions
    ) do
      def my_turn? = actor == player
    end
  end
end
