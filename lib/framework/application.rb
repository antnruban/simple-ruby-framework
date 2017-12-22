# frozen_string_literal: true

# NOTE: Application handles only one endpoint, but it can be easy improved.

module Framework
  class Application
    def self.call(env)
      @klass_name.new(env).response
    end

    def self.mount(endpoint_klass)
      @klass_name = endpoint_klass
    end
  end
end
