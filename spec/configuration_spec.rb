require 'spec_helper'

RSpec.describe LoogiHttp::Configuration do
  let(:config) { described_class.new conn }
  let(:conn) do
    double(
      Faraday::Connection,
      adapter: nil,
      request: nil,
      response: nil,
      use: nil
    )
  end
  let(:json_content_type) { 'application/json' }

  describe '#initialize' do
    it 'stores the connection for use later' do
      expect(config.send(:faraday_connection)).to eq conn
    end
  end

  describe '#configure' do
    it 'yields itself to the block' do
      config.configure do |value|
        @value = value
      end
      expect(@value).to eq config
    end

    context 'when ActiveSupport::Notifications is available' do
      before do
        Object.send :const_set, 'ActiveSupport', Module.new
        ActiveSupport.send :const_set, 'Notifications', Module.new
      end

      after do
        ActiveSupport.send :remove_const, 'Notifications'
        Object.send :remove_const, 'ActiveSupport'
      end

      it 'sets up instrumentation' do
        expect(conn).to receive(:use).with :instrumentation
        config.configure
      end
    end

    context 'when ActiveSupport::Notifications is not available' do
      it 'does not set up instrumentation' do
        expect(conn).to_not receive(:use).with :instrumentation
        config.configure
      end
    end

    context 'when a logger has been configured' do
      let(:level) { :debug }
      let(:logger) { double 'Logger' }

      before do
        LoogiHttp.logger = logger
        LoogiHttp.log_level = level
      end

      after do
        LoogiHttp.logger = nil
        LoogiHttp.log_level = nil
      end

      it 'sets up logging' do
        expect(conn).to receive(:use).with(
          :log_request,
          logger: logger,
          level: level
        )
        config.configure
      end
    end

    context 'when a logger has not been configured' do
      before do
        LoogiHttp.logger = nil
      end

      it 'does not set up logging' do
        expect(conn).to_not receive(:use).with :log_request, any_args
        config.configure
      end
    end

    it 'configures the adapter with the configured args and block',
       :aggregate_failures do
      arg1 = 1
      arg2 = :arg
      block = -> {}
      config.configure do |config|
        config.adapter arg1, arg2, &block
      end
      expect(config.send(:adapter_args)).to eq [arg1, arg2]
      expect(config.send(:adapter_block)).to eq block
    end

    it 'returns a Faraday connection' do
      expect(config.configure).to eq conn
    end
  end

  describe '#json' do
    it 'adds :json to the request and response stacks' do
      expect(conn).to receive(:request).with :accept_json
      expect(conn).to receive(:request).with :json
      expect(conn).to receive(:response).with :json, content_type: json_content_type
      config.json
    end
  end
end
