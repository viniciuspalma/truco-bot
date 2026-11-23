# frozen_string_literal: true

require 'trucobot'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { require it }

RSpec::Matchers.define_negated_matcher :exclude, :include

RSpec.configure do |config|
  config.expect_with(:rspec) { it.include_chain_clauses_in_custom_matcher_descriptions = true }
  config.mock_with(:rspec) { it.verify_partial_doubles = true }
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.include GameHelpers
end
