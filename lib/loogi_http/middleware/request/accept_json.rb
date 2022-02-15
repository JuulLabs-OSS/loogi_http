require 'faraday'

module LoogiHttp
  module Middleware
    # Faraday middleware to set `Accept` header to `application/json`.
    class AcceptJson < Faraday::Middleware
      # Set the `Accept` header to `application/json`. Overwrites existing
      # header.
      #
      # @param env [Faraday::Env]
      # @return [Faraday::Response]
      def call(env)
        headers = env[:request_headers]
        headers['Accept'] = 'application/json'
        @app.call env
      end
    end
  end
end
