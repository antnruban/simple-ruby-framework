# frozen_string_literal: true

module Framework
  class Application
    def self.call(env)
      MyEndpoint.new(env).response
    end
  end
end
