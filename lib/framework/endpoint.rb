# frozen_string_literal: true

# rubocop: disable Style/ParallelAssignment

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
      def headers(hash)
        define_method(:endpoint_headers) { hash }
      end

      def get(path, &bk)
        define_route(GET, path, &bk)
      end

      def post(path, &bk)
        define_route(POST, path, &bk)
      end

      def define_route(verb, path, &bk)
        define_method("#{verb}_#{path}", &bk)
      end
    end

    def initialize(env)
      @status  = SUCCESS_STATUS
      @request = Rack::Request.new(env)
      @headers = respond_to?(:endpoint_headers) ? endpoint_headers : {}
      @headers[CONTENT_TYPE_HEADER[:name]] ||= CONTENT_TYPE_HEADER[:value]
    end

    def response
      Rack::Response.new([call_endpoint_method.to_json], @status, @headers).finish
    end

    private

    def call_endpoint_method
      method_name = "#{@request.request_method}_#{@request.path}"
      raise RouteNotFound, "Route `#{@request.path}` not found." unless respond_to?(method_name)

      method(method_name).arity != 0 ? public_send(method_name, combined_params) : public_send(method_name)
    rescue => e
      error_response_handler(e)
    end

    def combined_params
      result = {}
      result.merge!(parse_json_body) unless @request.get?
      result.merge!(@request.params)
    end

    def parse_json_body
      raise UnsupportedMediaError, Rack::Utils::HTTP_STATUS_CODES[UNSUPPORTED_TYPE_CODE] unless json_content_type?

      JSON.parse(@request.body.gets, symbolize_names: true)
    end

    def json_content_type?
      @request.content_type == CONTENT_TYPE_HEADER[:value]
    end

    def error_response_handler(exception)
      @status, message = SERVER_ERROR_STATUS, Rack::Utils::HTTP_STATUS_CODES[SERVER_ERROR_STATUS]
      @status, message = NOT_FOUND_STATUS, exception.message      if exception.is_a?(RouteNotFound)
      @status, message = UNSUPPORTED_TYPE_CODE, exception.message if exception.is_a?(UnsupportedMediaError)

      { error: message }
    end
  end
end
