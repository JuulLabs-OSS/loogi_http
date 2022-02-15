require 'spec_helper'

RSpec.describe LoogiHttp::Builder do
  let(:builder) { described_class.new }
  let(:conn) do
    double(
      Faraday::Connection,
      adapter: nil,
      request: nil,
      response: nil,
      use: nil
    )
  end

  describe '#build' do
    before do
      allow(builder).to receive(:faraday_connection) do |&block|
        block&.call conn
      end
    end

    it 'creates a Faraday::Connection' do
      expect(builder).to receive(:faraday_connection)
      builder.build
    end

    it 'yields a Configuration to the block' do
      builder.build do |config|
        @config = config
      end
      expect(@config).to be_kind_of LoogiHttp::Configuration
    end

    it 'Configuration returns a wrapped Faraday connection' do
      expect(builder.build).to be_kind_of LoogiHttp::Connection
    end
  end

  context 'Faraday stacks' do
    context 'JSON' do
      let(:content_type) { 'Content-Type' }
      let(:headers) { { content_type => json_content_type } }
      let(:json) { { key: 'value' }.to_json }
      let(:json_content_type) { 'application/json' }
      let(:redirect) { 'Location' }
      let(:stack) do
        builder.build do |config|
          config.json
          config.adapter :test, stubs
        end
      end
      let(:status) { 200 }
      let(:stubs) do
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/test') do |_env|
            [status, headers, json]
          end
        end
      end

      it 'builds a Connection' do
        expect(stack).to be_kind_of LoogiHttp::Connection
      end

      it 'builds the correct stack', :aggregate_failures do
        result = stack.get '/test'
        expect(result).to be_finished
        expect(result.status).to eq 200
        expect(result).to be_success
        expect(result.body).to eq JSON.parse(json)
        expect(result.headers).to include content_type
      end

      it 'also follows redirects', :aggregate_failures do
        stubs.get('/redirect') do |_env|
          redirect_headers = {}
          redirect_headers[content_type] = 'text/plain'
          redirect_headers[redirect] = '/test'
          [301, redirect_headers, 'redirected']
        end

        result = stack.get '/redirect'
        expect(result).to be_finished
        expect(result).to be_success
        expect(result.status).to eq 200
        expect(result.body).to eq JSON.parse(json)
        expect(result.headers).to include content_type
      end
    end
  end
end
