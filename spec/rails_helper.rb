# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

module ControllerMatchers
  extend RSpec::Matchers::DSL

  matcher :have_assigned do |sym, expected|
    include RSpec::Matchers::Composable
    match do |actual|
      actual.call if actual.is_a?(Proc)
      values_match?(expected, assigns[sym])
    end
    description { "set @#{sym} to #{description_of(expected)}" }
  end
end

module AliasedMatchers
  def a_new(*args)
    be_a_new(*args)
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  # Rubocop (0.48.0) detects conditional mixins as if they were multiple mixins.
  #
  # rubocop:disable Style/MixinGrouping
  config.include ControllerMatchers, type: :controller
  config.include AliasedMatchers
  # rubocop:enable Style/MixinGrouping

  config.around(:example, :debug) do |example|
    old = ActiveRecord::Base.logger
    begin
      ActiveRecord::Base.logger = Logger.new($stderr)
      example.run
    ensure
      ActiveRecord::Base.logger = old
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
