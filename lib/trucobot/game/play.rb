# frozen_string_literal: true

module TrucoBot
  module Game
    # A card laid on the table by a player.
    Play = Data.define(:player, :card)
  end
end
