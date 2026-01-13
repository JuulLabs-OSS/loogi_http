require 'forwardable'
require 'faraday/follow_redirects'

module LoogiHttp
  # Configure a `Faraday::Connection` (aka a _stack_).
  class Configuration
    extend Forwardable

    # @param faraday_connection [Faraday::Connection] Stack to be
    #   configured
    def initialize(faraday_connection)
      @faraday_connection = faraday_connection
    end

    # Custom configuration of the stack in a block. By default, the
    # stack is configured to:
    #
    # * instrument call with `ActiveSupport::Notifications`
    # * follow redirects
    # * use `Net::HTTP` adapter
    #
    # Example:
    #
    # config.configure do |config|
    #   config.json
    # end
    #
    # @yield [config] Customize the stack within this block
    # @yieldparam config [LoogiHttp::Configuration] Configuration to customize
    # @return [Faraday::Connection]
    def configure(&_block)
      use :instrumentation if defined? ::ActiveSupport::Notifications

      logger = LoogiHttp.logger
      level = LoogiHttp.log_level
      use :log_request, logger: logger, level: level if logger

      response :follow_redirects

      yield self if block_given?

      use :debug_http
      faraday_connection.adapter(*adapter_args, &adapter_block)

      faraday_connection
    end

    # Configure the adapter to be used by the stack. The default stack is
    # `Net::HTTP`.
    #
    # Example customization of `Net::HTTP`:
    #
    # config.adapter :net_http do |http| # yields Net::HTTP
    #   http.idle_timeout = 100
    #   http.verify_callback = lambda do | preverify_ok, cert_store |
    #     # do something here...
    #   end
    # end
    #
    # More details in the Faraday docs
    # @see https://github.com/lostisland/faraday#ad-hoc-adapters-customization
    #
    # @param args [Array<Object>] Adapter arguments, name first, defaults to
    #   `:net_http`
    # @yield [adapter] Configure the adapter before use
    def adapter(*args, &block)
      @adapter_args = args
      @adapter_block = block
    end

    # Configure the stack for JSON, using three middlewares:
    #
    # * Set the `Accept` header
    # * ensure the body sent is JSON (converts non-String via `to_json`)
    # * parse result body as JSON for JSON content type
    def json
      request :accept_json
      request :json
      response :json, content_type: 'application/json'
    end

    private

    attr_reader :adapter_block, :faraday_connection

    def_delegators :@faraday_connection, :request, :response, :use

    def adapter_args
      @adapter_args ||= %i[net_http]
    end
  end
end
