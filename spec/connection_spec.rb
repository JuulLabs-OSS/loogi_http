require 'spec_helper'

RSpec.describe LoogiHttp::Connection do
  let(:body) { 'body' }
  let(:canned_response) do
    double(
      Faraday::Response,
      status: status_code,
      headers: headers,
      body: body
    )
  end
  let(:connection) { LoogiHttp::Connection.new faraday_conn }
  let(:faraday_conn) { double Faraday::Connection }
  let(:headers) { {} }
  let(:query_params) { { token: 'the-token' } }
  let(:status_code) { 200 }
  let(:url) { 'https://google.com' }

  let(:connection_failed) do
    Faraday::ConnectionFailed.new(RuntimeError.new('something failed'))
  end

  describe '#initialize' do
    it 'stores the Faraday connection' do
      expect(connection.send(:faraday_connection)).to eq faraday_conn
    end
  end

  shared_examples_for 'returning a LoogiHttp::Response' do
    it 'response is a LoogiHttp::Response' do
      expect(subject).to be_kind_of LoogiHttp::Response
    end

    it 'populates the LoogiHttp::Response', :aggregate_failures do
      response = subject
      expect(response.status).to eq status_code
      expect(response.headers).to eq headers
      expect(response.body).to eq body
    end
  end

  describe '#get' do
    before do
      allow(faraday_conn).to receive(:get).and_return canned_response
    end

    subject { connection.get url, params: query_params }

    it 'forwards the post to the underlying Faraday connection' do
      expect(faraday_conn).to receive(:get).with url, query_params
      subject
    end

    it_behaves_like 'returning a LoogiHttp::Response'

    context 'when faraday raises a Faraday::TimeoutError' do
      before do
        allow(faraday_conn).to receive(:get).and_raise Faraday::TimeoutError
      end

      it 'rescues Faraday::TimeoutError and raises a LoogiHttp::TimeoutError' do
        expect { subject }.to raise_error(LoogiHttp::TimeoutError)
      end
    end

    context 'when faraday raises a Faraday::ConnectionFailed' do
      before do
        allow(faraday_conn).to receive(:get).and_raise(connection_failed)
      end

      it 'raises a LoogiHttp::ConnectionFailed' do
        expect { subject }.to raise_error(LoogiHttp::ConnectionFailed)
      end
    end
  end

  describe '#post' do
    let(:data) { { data: 'data' } }
    let(:headers) { { something: 'data' } }
    let(:params) { double(Faraday::Utils::ParamsHash).as_null_object }
    let(:request) { double(Faraday::Request).as_null_object }
    let(:status_code) { 201 }

    before do
      allow(faraday_conn).to receive(:post) do |*_args, &block|
        block&.call request
        canned_response
      end
    end

    subject do
      connection.post url, params: query_params, data: data, headers: headers
    end

    it 'forwards the post to the underlying Faraday connection' do
      expect(faraday_conn).to receive(:post).with url, data, headers
      subject
    end

    it 'merges in the params' do
      expect(request).to receive(:params).and_return params
      expect(params).to receive(:update).with query_params
      subject
    end

    it_behaves_like 'returning a LoogiHttp::Response'

    context 'when faraday raises a Faraday::TimeoutError' do
      before do
        allow(faraday_conn).to receive(:post).and_raise Faraday::TimeoutError
      end

      it 'rescues Faraday::TimeoutError and raises a LoogiHttp::TimeoutError' do
        expect { subject }.to raise_error(LoogiHttp::TimeoutError)
      end
    end

    context 'when faraday raises a Faraday::ConnectionFailed' do
      before do
        allow(faraday_conn).to receive(:post).and_raise(connection_failed)
      end

      it 'raises a LoogiHttp::ConnectionFailed' do
        expect { subject }.to raise_error(LoogiHttp::ConnectionFailed)
      end
    end
  end

  describe '#put' do
    let(:data) { { data: 'data' } }
    let(:headers) { { something: 'data' } }
    let(:params) { double(Faraday::Utils::ParamsHash).as_null_object }
    let(:request) { double(Faraday::Request).as_null_object }
    let(:status_code) { 201 }

    before do
      allow(faraday_conn).to receive(:put) do |*_args, &block|
        block&.call request
        canned_response
      end
    end

    subject do
      connection.put url, params: query_params, data: data, headers: headers
    end

    it 'forwards the post to the underlying Faraday connection' do
      expect(faraday_conn).to receive(:put).with url, data, headers
      subject
    end

    it 'merges in the params' do
      expect(request).to receive(:params).and_return params
      expect(params).to receive(:update).with query_params
      subject
    end

    it_behaves_like 'returning a LoogiHttp::Response'

    context 'when faraday raises a Faraday::TimeoutError' do
      before do
        allow(faraday_conn).to receive(:put).and_raise Faraday::TimeoutError
      end

      it 'rescues Faraday::TimeoutError and raises a LoogiHttp::TimeoutError' do
        expect { subject }.to raise_error(LoogiHttp::TimeoutError)
      end
    end
  end

  describe '#basic_auth' do
    subject { connection.basic_auth(username: username, password: password) }

    let(:username) { 'username' }
    let(:password) { 'password' }

    it 'calls the faraday method of the same name' do
      expect(faraday_conn).
        to receive(:basic_auth).
        with(
          username,
          password
        )

      subject
    end
  end
end
