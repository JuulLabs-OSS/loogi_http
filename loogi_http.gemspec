lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'loogi_http/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.6'
  spec.name          = 'loogi_http'
  spec.version       = LoogiHttp::VERSION
  spec.authors       = ['Juul Labs, Inc.']
  spec.email         = ['opensource@juul.com']

  spec.summary       = 'External requests wrapper.'
  spec.description   = 'Provides a wrapper to external requests providing ' \
                       'JSON parsing, logging, metrics, and more.'
  spec.homepage      = 'https://github.com/JuulLabs-OSS/loogi_http'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.
      split("\x0").
      reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 1.0'
  spec.add_dependency 'faraday-cookie_jar', '~> 0.0.6'
  spec.add_dependency 'faraday_middleware', '~> 1.0.0'

  spec.add_development_dependency 'bundler', '>= 2.0'
  spec.add_development_dependency 'byebug', '~> 11.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.5.1'
end
