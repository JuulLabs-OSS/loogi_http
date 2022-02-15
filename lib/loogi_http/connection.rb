require 'loogi_http/response'
require 'loogi_http/error'

module LoogiHttp
  # HTTP connection over a configured `Faraday::Connection` (aka a _stack_).
  # Methods supported are:
  #
  # {#get}
  # {#post}
  class Connection
    # @param faraday_connection [Faraday::Connection] The configured
    #   `Faraday::Connection`
    def initialize(faraday_connection)
      @faraday_connection = faraday_connection
    end

    # HTTP GET request.
    #
    # @param url [String] URL
    # @param params [Hash] Query params to be sent, defaults to `{}`
    # @return [LoogiHttp::Response]
    def get(url, params: {})
      response faraday_connection.get(url, params)
    rescue Faraday::TimeoutError => e
      raise LoogiHttp::TimeoutError, e
    rescue Faraday::ConnectionFailed => e
      raise LoogiHttp::ConnectionFailed, e
    end

    # HTTP POST request.
    #
    # @param url [String] URL
    # @param params [Hash] Query params to be sent, defaults to `{}`
    # @param data [Object] POST body that will eventually be converted into a
    #   `String`, defaults to `nil`
    # @param options [Hash] Faraday options, defaults to `{}`
    # @param headers [Hash] Headers for the POST, defaults to `{}`
    # @return [LoogiHttp::Response]
    def post(url, params: {}, data: nil, options: {}, headers: {})
      response(faraday_connection.post(url, data, headers) do |request|
        request.params.update params if params
        if (debug = options.delete(:debug))
          options[:context] ||= {}
          options[:context][:debug] = debug
        end
        request.options.update options if options
      end)
    rescue Faraday::TimeoutError => e
      raise LoogiHttp::TimeoutError, e
    rescue Faraday::ConnectionFailed => e
      raise LoogiHttp::ConnectionFailed, e
    end

    # HTTP PUT request.
    #
    # @param url [String] URL
    # @param params [Hash] Query params to be sent, defaults to `{}`
    # @param data [Object] PUT body that will eventually be converted into a
    #   `String`, defaults to `nil`
    # @param options [Hash] Faraday options, defaults to `{}`
    # @param headers [Hash] Headers for the PUT, defaults to `{}`
    # @return [LoogiHttp::Response]
    def put(url, params: {}, data: nil, options: {}, headers: {})
      response(faraday_connection.put(url, data, headers) do |request|
        request.params.update params if params
        if (debug = options.delete(:debug))
          options[:context] ||= {}
          options[:context][:debug] = debug
        end
        request.options.update options if options
      end)
    rescue Faraday::TimeoutError => e
      raise LoogiHttp::TimeoutError, e
    end

    # Basic Authentication
    #
    # @param username [String]
    # @param password [String]
    #
    # @return [void]
    def basic_auth(username:, password:)
      faraday_connection.basic_auth(username, password)
    end

    private

    attr_reader :faraday_connection

    def response(faraday_response)
      Response.new(faraday_response)
    end
  end
end
