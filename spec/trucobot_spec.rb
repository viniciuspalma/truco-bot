# frozen_string_literal: true

RSpec.describe TrucoBot do
  it 'has a version number' do
    expect(TrucoBot::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
