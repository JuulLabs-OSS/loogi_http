require 'spec_helper'

RSpec.describe LoogiHttp::Middleware::AcceptJson do
  let(:app) { double 'app' }
  let(:env) { { request_headers: Faraday::Utils::Headers.new } }
  let(:middleware) { described_class.new app }

  shared_examples_for 'setting the Accept header' do
    it 'to application/json' do
      allow(app).to receive(:call) do |env|
        headers = env[:request_headers]
        expect(headers['Accept']).to eq 'application/json'
      end
      middleware.call env
    end
  end

  describe '#call' do
    it 'calls down the stack' do
      expect(app).to receive(:call).with(env)
      middleware.call env
    end

    it_behaves_like 'setting the Accept header'

    context 'when the Accept header was already set' do
      before { env[:request_headers][:accept] = '*/*' }
      it_behaves_like 'setting the Accept header'
    end
  end
end
