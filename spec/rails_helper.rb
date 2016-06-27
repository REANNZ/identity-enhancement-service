# frozen_string_literal: true
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

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
  config.use_transactional_fixtures = false
  config.include ControllerMatchers, type: :controller
  config.include AliasedMatchers
  config.include DeleteButton, type: :feature, js: true

  config.around(:example, :debug) do |example|
    old = ActiveRecord::Base.logger
    begin
      ActiveRecord::Base.logger = Logger.new($stderr)
      example.run
    ensure
      ActiveRecord::Base.logger = old
    end
  end

  Capybara.default_driver = Capybara.javascript_driver = :poltergeist

  config.before(:each, type: :feature) do
    page.driver.reset!
    page.driver.browser.url_blacklist = %w(https://fonts.googleapis.com)
  end

  config.verbose_retry = true
  config.default_retry_count = 1
  config.default_retry_count = 3 if ENV['CI']

  config.exceptions_to_retry = [Capybara::Poltergeist::TimeoutError]
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
