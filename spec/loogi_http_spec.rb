require 'logger'

RSpec.describe LoogiHttp do
  def with_temp_logger(&_block)
    raise ArgumentError('Block required') unless block_given?

    string_io = StringIO.new
    logger = Logger.new(string_io)
    yield logger
    string_io.rewind
    string_io.readlines
  end

  it 'has a version number' do
    expect(LoogiHttp::VERSION).not_to be nil
  end

  context 'logging configuration' do
    let(:level) { :debug }
    let(:logger) { double 'Logger' }

    after do
      LoogiHttp.logger = nil
      LoogiHttp.log_level = nil
    end

    it 'allows a logger to be set' do
      LoogiHttp.logger = logger
      expect(LoogiHttp.logger).to eq logger
    end

    it 'allows a log level to be set' do
      LoogiHttp.log_level = level
      expect(LoogiHttp.log_level).to eq level
    end

    it 'defaults the log level to info' do
      expect(LoogiHttp.log_level).to eq :info
    end
  end

  context 'full stack testing' do
    let(:content_type_header) { { 'Content-Type' => json_content_type } }
    let(:json_content_type) { 'application/json' }
    let(:payload) { { 'name' => 'test', 'value' => 'test' } }
    let(:token) { 'api-token' }
    let(:tokenized_url) { url + "?token=#{token}" }
    let(:url) { 'https://example.com/api' }
    let(:request_headers) do
      content_type_header.merge 'Accept' => json_content_type
    end
    let(:response_body) { { response: true }.to_json }

    describe '.json_post' do
      before do
        stub_request(:post, tokenized_url).
          with(body: payload.to_json, headers: request_headers).
          to_return(
            status: 201,
            body: response_body,
            headers: content_type_header
          )
      end

      it 'makes the correct request' do
        LoogiHttp.json_post(url, params: { token: token }, data: payload)
      end

      it 'returns a JSON response', :aggregate_failures do
        response = LoogiHttp.json_post(
          url,
          params: { token: token },
          data: payload
        )
        expect(response).to be_finished
        expect(response).to be_success
        expect(response.status).to eq 201
        expect(response.body).to eq JSON.parse(response_body)
        expect(response.headers).to include content_type_header
      end
    end

    context 'logging' do
      before do
        stub_request(:post, tokenized_url).
          with(body: payload.to_json, headers: request_headers).
          to_return(
            status: 201,
            body: response_body,
            headers: content_type_header
          )
      end

      it 'logs the HTTP request', :aggregate_failures do
        logged_lines = with_temp_logger do |logger|
          LoogiHttp.logger = logger
          LoogiHttp.json_post(
            url,
            params: { token: token },
            data: payload
          )
        end

        uri = URI(url)
        expect(logged_lines).to include a_string_matching(/INFO/)
        expect(logged_lines).to include a_string_matching(/POST/)
        expect(logged_lines).to include a_string_matching(/201/)
        expect(logged_lines).to include a_string_matching(/#{uri.host}/)
        expect(logged_lines).to include a_string_matching(/#{uri.path}/)
      end
    end

    context 'debug option' do
      before do
        stub_request(:post, tokenized_url).
          with(body: payload.to_json, headers: request_headers).
          to_return(
            status: 201,
            body: response_body,
            headers: content_type_header
          )
      end

      it 'logs the HTTP request', :aggregate_failures do
        logged_lines = with_temp_logger do |logger|
          LoogiHttp.json_post(
            url,
            params: { token: token },
            data: payload,
            options: { debug: logger }
          )
        end

        expect(logged_lines).to include a_string_matching(/POST/)
        expect(logged_lines).to include a_string_matching(/Host:/)
        expect(logged_lines).to include a_string_matching(/Accept: #{json_content_type}/)
        expect(logged_lines).to include a_string_matching(/#{response_body}/)
      end
    end
  end
end
