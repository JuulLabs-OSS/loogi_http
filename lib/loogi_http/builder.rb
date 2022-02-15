require 'loogi_http/configuration'
require 'loogi_http/connection'

module LoogiHttp
  # Conveniently configure `Faraday` stacks.
  class Builder
    # Configure a JSON stack.
    #
    # @return [LoogiHttp::Connection]
    def self.json
      new.build(&:json)
    end

    # Customize a stack with a configuration block.
    #
    # Example:
    #
    # LoogiHttp::Builder.new.configure do |config|
    #   config.json
    # end
    #
    # @yield [config] Customize the stack within this block
    # @yieldparam config [LoogiHttp::Configuration] Configuration to customize
    # @return [LoogiHttp::Connection]
    def build(&block)
      LoogiHttp::Connection.new(
        faraday_connection do |conn|
          LoogiHttp::Configuration.new(conn).configure(&block)
        end
      )
    end

    private

    def faraday_connection(&block)
      Faraday.new(&block)
    end
  end
end
