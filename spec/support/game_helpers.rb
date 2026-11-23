# frozen_string_literal: true

module GameHelpers
  include TrucoBot::Game

  def player(id) = Player.new(id:)

  def rules(**) = Rules.new(**)

  def scoreboard_for(players, target: 30) = Scoreboard.new(players, target:)

  def card(rank, suit) = Card.new(rank:, suit:)

  def action(name, card = nil) = Action.new(name:, card:)

  def action_names(actions) = actions.map(&:name).uniq

  # Plays the given cards in order, alternating between whoever is to move.
  def play_cards(game, *cards)
    cards.each { |played| game.act(game.actor, action(:play_card, played)) }
  end
end
