# frozen_string_literal: true

module ActionController
  module TestResponseStringOverride
    def to_s
      status, headers, body = to_a
      body = ''.dup.tap { |out| body.each { |s| out << s } }
      "#<#{self.class.name} #{request.method} #{request.fullpath} => " \
        "[#{status}, #{body.inspect}, #{headers.inspect}]>"
    end

    def inspect
      to_s
    end
  end

  RSpec.configure do |config|
    config.before(:suite) do
      if defined?(TestResponse)
        TestResponse.send(:include, TestResponseStringOverride)
      end
    end
  end
end
