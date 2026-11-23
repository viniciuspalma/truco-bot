# frozen_string_literal: true

module TrucoBot
  module Game
    Action = Data.define(:name, :card)

    # Something a player does on their turn. Every legal option is listed by
    # Match#allowed_actions, so a UI or an AI can pick one and hand it back.
    class Action
      TRUCO_CALLS = %i[truco retruco vale_cuatro].freeze
      ENVIDO_CALLS = %i[envido real_envido falta_envido].freeze
      FLOR_ANSWERS = %i[contraflor contraflor_al_resto con_flor_me_achico].freeze
      ANSWERS = %i[quiero no_quiero].freeze
      NAMES = [:play_card, *TRUCO_CALLS, *ENVIDO_CALLS, :flor, *FLOR_ANSWERS, *ANSWERS, :al_mazo].freeze

      def self.play(card) = new(name: :play_card, card:)

      # Accepts an Action, or a name plus an optional card:
      #   Action.coerce(:quiero)
      #   Action.coerce(:play_card, card)
      def self.coerce(action, card = nil)
        action.is_a?(self) ? action : new(name: action.to_sym, card:)
      end

      def initialize(name:, card: nil)
        raise ArgumentError, "unknown action: #{name.inspect}" unless NAMES.include?(name)
        raise ArgumentError, 'play_card needs a card' if name == :play_card && card.nil?
        raise ArgumentError, "#{name} does not take a card" if name != :play_card && card

        super
      end

      def play_card? = name == :play_card
      def truco_call? = TRUCO_CALLS.include?(name)
      def envido_call? = ENVIDO_CALLS.include?(name)
      def flor_answer? = FLOR_ANSWERS.include?(name)

      def to_s = play_card? ? "play #{card}" : name.to_s
    end
  end
end
