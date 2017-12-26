# frozen_string_literal: true

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

ENV['RACK_ENV'] = 'test'

require 'rack/test'
require File.expand_path('../../config/application.rb', __FILE__)
Dir['./spec/support/**/*.rb'].each { |file| require file }

RSpec.configure do |config|
  config.include TestMethods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
