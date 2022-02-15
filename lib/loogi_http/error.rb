module LoogiHttp
  class Error < RuntimeError; end

  class ServerError < Error
    attr_reader :error

    def initialize(error)
      @error = error
      set_backtrace(error.backtrace)
    end

    def message
      error.message
    end
  end

  class TimeoutError < ServerError; end

  class ConnectionFailed < ServerError; end
end
