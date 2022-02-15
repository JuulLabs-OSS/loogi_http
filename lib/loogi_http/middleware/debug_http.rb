require 'faraday'

module LoogiHttp
  module Middleware
    # Faraday middleware to debug the request and response.
    #
    # Turn on per request by passing a Logger as the `:debug` option:
    #
    # LoogiHttp.json_post url, params, data, debug: Rails.logger
    class DebugHttp < Faraday::Middleware
      class DebugOutput
        def initialize(env, response, exception)
          @env = env
          @response = response
          @exception = exception
        end

        def debug
          debug_request

          if response
            debug_line
            debug_response
          end

          return if exception.nil?

          debug_line
          debug_exception
        end

        private

        attr_reader :env, :exception, :response

        def debug_exception
          klass = exception.class
          error = exception.message
          trace = exception.backtrace.join("\n")
          exception_message = format(
            "%<klass>s %<error>s\n%<trace>s",
            klass: klass,
            error: error,
            trace: trace
          )
          logger.info exception_message
        end

        def debug_line
          logger.info ''
        end

        def debug_request
          url = env.url
          method = env.method.to_s.upcase

          logger.info "#{method} #{url.path}"
          logger.info "Host: #{url.host}"
          log_headers env.request_headers
          log_body env.body if needs_body?
        end

        def debug_response
          logger.info "Status: #{response.status}"
          log_headers response.headers
          log_body response.body
        end

        def log_body(body)
          logger.info 'BODY' + '-' * 10
          logger.info body
          logger.info 'BODY' + '-' * 10
        end

        def log_headers(headers_hash)
          headers_hash.each do |key, value|
            logger.info "#{key}: #{value}"
          end
        end

        def logger
          @logger ||= env.request.context[:debug]
        end

        def needs_body?
          Faraday::Env::MethodsWithBodies.include? env.method
        end
      end

      # Emit debug output for every request. If an exception is raised, emit the
      # exception and backtrace.
      #
      # @param env [Faraday::Env]
      # @return [Faraday::Request]
      def call(env)
        if debug?(env)
          debug_call env
        else
          @app.call env
        end
      end

      private

      def debug?(env)
        env.request.context&.send(:[], :debug)
      end

      def debug_call(env)
        exception = nil
        response = @app.call(env)
      rescue StandardError => e
        exception = e
        raise
      ensure
        debug_output env, response, exception
      end

      def debug_output(env, response, exception)
        DebugOutput.new(env, response, exception).debug
      end
    end
  end
end
