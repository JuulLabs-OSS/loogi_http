require 'faraday'

# Monkey patches to properly delegate Faraday 1.0 keyword arguments on Ruby 3
# See https://eregon.me/blog/2021/02/13/correct-delegation-in-ruby-2-27-3.html

Faraday::DependencyLoader.module_eval do
  def new(*args, &block)
    raise "missing dependency for #{self}: #{load_error.message}" unless loaded?

    super(*args, &block)
  end

  ruby2_keywords :new if respond_to?(:ruby2_keywords, true)
end

Faraday::RackBuilder::Handler.class_eval do
  def initialize(klass, *args, &block)
    @name = klass.to_s
    Faraday::RackBuilder::Handler::REGISTRY.set(klass) if klass.respond_to?(:name)
    @args = args
    @block = block
  end

  ruby2_keywords :initialize if respond_to?(:ruby2_keywords, true)
end
