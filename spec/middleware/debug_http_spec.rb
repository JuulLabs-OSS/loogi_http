require 'spec_helper'
require 'logger'

RSpec.describe LoogiHttp::Middleware::DebugHttp do
  let(:app) { double 'app' }
  let(:canned_response) do
    double(
      Faraday::Response,
      status: 200,
      headers: {},
      body: 'body'
    )
  end
  let(:env) do
    Faraday::Env.new.tap do |env|
      env.request_headers = Faraday::Utils::Headers.new
      env.request = Faraday::RequestOptions.new
    end
  end
  let(:logger) { spy Logger }
  let(:middleware) { described_class.new app }

  describe '#call' do
    before do
      allow(app).to receive(:call).with(env).and_return canned_response
      allow(middleware).
        to receive(:debug_output)
    end

    shared_examples_for 'default call behavior' do
      it 'calls down the stack' do
        expect(app).to receive(:call).with env
        middleware.call env
      end

      it 'returns the Faraday::Response' do
        expect(middleware.call(env)).to eq canned_response
      end
    end

    context 'when debug is not enabled' do
      it_behaves_like 'default call behavior'
    end

    context 'when debug is enabled' do
      before { env.request.context = { debug: logger } }

      it_behaves_like 'default call behavior'
    end
  end
end
