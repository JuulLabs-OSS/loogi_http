module LoogiHttp
  module Middleware
    autoload :AcceptJson, 'loogi_http/middleware/request/accept_json'
    autoload :DebugHttp, 'loogi_http/middleware/debug_http'
    autoload :LogRequest, 'loogi_http/middleware/log_request'
  end
end
