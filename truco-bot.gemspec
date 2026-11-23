# frozen_string_literal: true

require_relative 'lib/trucobot/version'

Gem::Specification.new do |spec|
  spec.name          = 'truco-bot'
  spec.version       = TrucoBot::VERSION
  spec.authors       = ['Vinícius Palma']
  spec.email         = ['viniwpalma@gmail.com']

  spec.summary       = 'Argentine Truco rules engine, built to power a Slack bot.'
  spec.description   = 'A complete 1v1 Truco engine: hands of three tricks, Truco/Retruco/Vale Cuatro, ' \
                       'Envido/Real Envido/Falta Envido, optional Flor and scoring to 30, exposed as a ' \
                       'state machine that tells callers whose turn it is and which actions are legal.'
  spec.homepage      = 'https://github.com/viniciuspalma/truco-bot'
  spec.required_ruby_version = '>= 4.0'

  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['lib/**/*.rb', 'README.md']
  spec.require_paths = ['lib']
end
