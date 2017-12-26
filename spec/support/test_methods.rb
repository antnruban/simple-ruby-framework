# frozen_string_literal: true

module TestMethods
  include Rack::Test::Methods

  def app
    Application
  end

  def json_body
    JSON.parse(last_response.body, symbolize_names: true)
  end

  alias response last_response
  alias request  last_request
end

RSpec::Matchers.define :have_constant do |const|
  match do |owner|
    owner.const_defined?(const)
  end
end
