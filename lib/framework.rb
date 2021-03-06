# frozen_string_literal: true

require 'json'
require 'framework/endpoint'
require 'framework/application'

module Framework
  VERSION = '0.0.1'

  def self.version
    VERSION
  end
end

# Application Erros.

class UnsupportedMediaError < StandardError; end
class RouteNotFound < StandardError; end
