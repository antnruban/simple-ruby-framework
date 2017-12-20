# frozen_string_literal: true

class Framework
  GET = 'GET'
  POST = 'POST'

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
    @request = Rack::Request.new(env)
    @combined_params = combined_params
    @status = 200
    @headers = @@headers
    @headers['Content-Type'] ||= 'application/json'
  end

  def response
    [@status, @headers, [call_endpoint_method.to_json]]
  end

  private

  def combined_params
    result = Hashie::Mash.new
    result.merge!(parse_json_body)
    result.merge!(@request.params)
  end

  def parse_json_body
    return {} unless @request.env['CONTENT_TYPE'] == 'application/json'

    JSON.parse(@request.body.gets)
  end

  def call_endpoint_method
    method_name = "#{@request.request_method}_#{@request.path}"
    method(method_name).arity != 0 ? public_send(method_name, @combined_params) : public_send(method_name)
  rescue => e
    handle_error_response(e)
  end

  def handle_error_response(exception)
    @status = 500
    message = exception.message

    if exception.is_a?(NameError) && exception.message.match?(/#{GET}|#{POST}/)
      @status = 404
      message = "Route `#{@request.path}` not found."
    end

    { error: message }
  end
end
