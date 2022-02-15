require 'faraday'

module LoogiHttp
  module Middleware
    # Faraday middleware to log request to `Logger`.
    class LogRequest < Faraday::Middleware
      # @param logger [Logger] Logger instance to log to
      # @param level [Symbol | String] Log level to use
      def initialize(app, logger:, level: :info)
        super app
        @level = level
        @logger = logger
      end

      # Log the following for every request made:
      #
      # * host
      # * HTTP method
      # * uri
      # * status
      # * duration
      #
      # If an exception is raised, log the exception and backtrace.
      #
      # @param env [Faraday::Env]
      # @return [Faraday::Request]
      def call(env)
        start_time = Time.now
        exception = nil
        @app.call env
      rescue StandardError => e
        exception = e
        raise
      ensure
        duration = Time.now - start_time
        log_message env, duration
        log_exception(exception) if exception
      end

      private

      attr_reader :level, :logger

      def log_exception(exception)
        klass = exception.class
        error = exception.message
        trace = exception.backtrace.join("\n")
        exception_message = format(
          "%<klass>s %<error>s\n%<trace>s",
          klass: klass,
          error: error,
          trace: trace
        )
        logger.send level, exception_message
      end

      def log_message(env, duration)
        url = env.url
        method = env.method.to_s.upcase
        status = env.status || 500

        message = format(
          '[%<host>s] %<method>s %<uri>s %<status>d (%<duration>.3f s)',
          host: url.host,
          method: method,
          uri: url.path,
          status: status,
          duration: duration
        )
        logger.send level, message
      end
    end
  end
end
