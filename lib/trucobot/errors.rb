# frozen_string_literal: true

module TrucoBot
  class Error < StandardError; end

  # Raised when a player tries an action the rules do not allow right now.
  class IllegalAction < Error; end
end
