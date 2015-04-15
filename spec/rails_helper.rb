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

module NoTransactionalFixtures
  def self.included(base)
    base.class_eval { self.use_transactional_fixtures = false }
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include ControllerMatchers, type: :controller
  config.include AliasedMatchers
  config.include NoTransactionalFixtures, type: :feature
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

  Capybara.javascript_driver = :poltergeist

  config.before(:suite) { DatabaseCleaner.strategy = :truncation }
  config.before(:each, type: :feature) { DatabaseCleaner.start }
  config.after(:each, type: :feature) { DatabaseCleaner.clean }
end
