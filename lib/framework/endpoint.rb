# frozen_string_literal: true

module Framework
  class Endpoint
    # HTTP methods.
    GET  = 'GET'
    POST = 'POST'

    # Status codes.
    SUCCESS_STATUS        = 200
    NOT_FOUND_STATUS      = 404
    UNSUPPORTED_TYPE_CODE = 415
    SERVER_ERROR_STATUS   = 500

    # Headers.
    CONTENT_TYPE_HEADER = { name: 'Content-Type', value: 'application/json' }.freeze

    class << self
      @@headers = {}

      def headers(hash)
        @@headers = hash
      end

      def get(path, &bk)
        define_route(GET, path, &bk)
      end

      def post(path, &bk)
        define_route(POST, path, &bk)
      end

      def define_route(verb, path, &bk)
        method_name = "#{verb}_#{path}"
        define_method(method_name, &bk)
      end
    end

    def initialize(env)
      @headers = @@headers
      @status = SUCCESS_STATUS
      @request = Rack::Request.new(env)
      @combined_params = combined_params
      @headers[CONTENT_TYPE_HEADER[:name]] ||= CONTENT_TYPE_HEADER[:value]
    end

    def response
      [@status, @headers, [call_endpoint_method.to_json]]
    end

    private

    def combined_params
      result = {}
      result.merge!(parse_json_body)
      result.merge!(@request.params)
    end

    def parse_json_body
      return {} unless @request.content_type == CONTENT_TYPE_HEADER[:value]

      JSON.parse(@request.body.gets, symbolize_names: true)
    end

    def call_endpoint_method
      method_name = "#{@request.request_method}_#{@request.path}"
      method(method_name).arity != 0 ? public_send(method_name, @combined_params) : public_send(method_name)
    rescue => e
      error_response_handler(e)
    end

    def error_response_handler(exception)
      @status = SERVER_ERROR_STATUS
      message = exception.message

      if exception.message.match?(/method `#{GET}|#{POST}/)
        @status = NOT_FOUND_STATUS
        message = "Route `#{@request.path}` not found."
      end

      { error: message }
    end
  end
end
