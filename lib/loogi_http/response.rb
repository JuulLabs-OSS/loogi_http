require 'forwardable'

module LoogiHttp
  # Wraps a `Faraday::Response`.
  class Response
    extend Forwardable

    def_delegators :@faraday_response, :body, :finished?, :headers, :status,
                   :success?

    # @param faraday_response [Faraday::Response] The wrapped `Response`
    def initialize(faraday_response)
      @faraday_response = faraday_response
    end
  end
end
