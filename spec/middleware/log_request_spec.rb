require 'spec_helper'
require 'logger'

RSpec.describe LoogiHttp::Middleware::LogRequest do
  let(:app) { double 'app' }
  let(:canned_response) do
    double(
      Faraday::Response,
      status: 200,
      headers: {},
      body: 'body'
    )
  end
  let(:env) { { request_headers: Faraday::Utils::Headers.new } }
  let(:level) { :info }
  let(:logger) { spy Logger }
  let(:middleware) { described_class.new app, logger: logger, level: level }

  describe '#initialize' do
    it 'saves the logging level' do
      expect(middleware.send(:level)).to eq level
    end
  end

  describe '#call' do
    before do
      allow(middleware).to receive :log_exception
      allow(middleware).to receive :log_message
    end

    shared_examples_for 'logs the request' do
      # rubocop:disable Lint/SuppressedException
      it 'to the Logger' do
        allow(middleware).to receive :log_exception
        expect(middleware).to receive :log_message
        begin
          middleware.call env
        rescue Faraday::TimeoutError
        end
      end
      # rubocop:enable Lint/SuppressedException
    end

    it 'calls down the stack' do
      expect(app).to receive(:call).with env
      middleware.call env
    end

    context 'when there is no exception' do
      before { allow(app).to receive(:call).and_return canned_response }

      it_behaves_like 'logs the request'

      it 'does not log an exception' do
        expect(middleware).to_not receive :log_exception
        middleware.call env
      end

      it 'returns the Faraday::Response' do
        expect(middleware.call(env)).to eq canned_response
      end
    end

    context 'when there is an exception' do
      before do
        allow(app).to receive(:call).and_raise Faraday::TimeoutError
      end

      it_behaves_like 'logs the request'

      # rubocop:disable Lint/SuppressedException
      it 'does log an exception' do
        expect(middleware).to receive :log_exception
        begin
          middleware.call env
        rescue Faraday::TimeoutError
        end
      end
      # rubocop:enable Lint/SuppressedException

      it 'reraises the exception' do
        expect do
          middleware.call env
        end.to raise_error Faraday::TimeoutError
      end
    end
  end
end
