# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 4.2.2'

gem 'aaf-lipstick', git: 'https://github.com/ausaccessfed/aaf-lipstick',
                    branch: 'b9533adbe0ee5623ebe890a1ecbd429751c24a2d'
gem 'accession'
gem 'jbuilder'
gem 'jquery-rails'
gem 'mysql2'
gem 'rapid-rack'
gem 'redis'
gem 'redis-rails'
gem 'sass-rails'
gem 'therubyracer'
gem 'uglifier'
gem 'valhammer'

gem 'audited-activerecord'

gem 'god', require: false
gem 'unicorn', require: false

source 'https://rails-assets.org' do
  gem 'rails-assets-jquery', '~> 1.11'
  gem 'rails-assets-pickadate', '3.5.6'
  gem 'rails-assets-semantic-ui', '~> 2.0'
end

group :development, :test do
  gem 'aaf-gumboot'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'nokogiri', '~> 1.7.1'
  gem 'poltergeist'
  gem 'rspec-rails', '~> 3.1'
  gem 'rspec-retry'
  gem 'shoulda-matchers'
  gem 'timecop'

  gem 'brakeman', '~> 2.6', require: false
  gem 'codeclimate-test-reporter', require: false
  gem 'pry', require: false
  gem 'simplecov', require: false

  gem 'guard', require: false
  gem 'guard-brakeman', require: false
  gem 'guard-bundler', require: false
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-unicorn', require: false
  gem 'terminal-notifier-guard', require: false
end
