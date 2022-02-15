require 'loogi_http/ruby2_keywords'
require 'loogi_http/builder'
require 'loogi_http/version'
require 'loogi_http/middleware'
require 'faraday'

module LoogiHttp
  # The log level to use with the logger. Defaults to `info`.
  def self.log_level
    @log_level ||= :info
  end

  # Set the log level to use with the logger
  #
  # @param log_level [Symbol | String] Logging level
  def self.log_level=(log_level)
    @log_level = log_level
  end

  # The Logger to use when logging
  def self.logger
    @logger ||= nil # Silence warning
  end

  # Set the Logger to use when logging
  #
  # @param logger [Logger] The logger to log to
  def self.logger=(logger)
    @logger = logger
  end

  # HTTP POST with JSON data sent and expected as the response.
  #
  # (see LoogiHttp::Connection#post)
  # @param options [Hash] Options for the JSON POST
  def self.json_post(url, params: {}, data: nil, options: {})
    LoogiHttp::Builder.json.post(
      url,
      params: params,
      data: data,
      options: options
    )
  end

  Faraday::Request.register_middleware accept_json: -> { Middleware::AcceptJson }
  Faraday::Middleware.register_middleware log_request: -> { Middleware::LogRequest }
  Faraday::Middleware.register_middleware debug_http: -> { Middleware::DebugHttp }
end
