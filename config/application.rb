# frozen_string_literal: true

# Require all gems listed at Gemfile.
require File.expand_path('../boot', __FILE__)

# Require application endpoints bellow.
require './app/my_endpoint'

class Application < Framework::Application
  # Mount application endpoints bellow.
  mount MyEndpoint
end
