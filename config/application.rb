# frozen_string_literal: true

# Require all gems listed at Gemfile.
require File.expand_path('../boot', __FILE__)

# Require application endpoints bellow.
require './app/endpoint'

class Application
  def self.call(env)
    Endpoint.new(env).response
  end
end
