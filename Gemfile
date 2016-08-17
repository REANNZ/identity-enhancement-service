# frozen_string_literal: true
source 'https://rubygems.org'

gem 'rails', '~> 4.2.2'
gem 'sass-rails'
gem 'uglifier'
gem 'therubyracer'
gem 'jbuilder'
gem 'jquery-rails'
gem 'mysql2'
gem 'redis'
gem 'redis-rails'
gem 'audited-activerecord'
gem 'rapid-rack'
gem 'accession'
gem 'aaf-lipstick', git: 'https://github.com/ausaccessfed/aaf-lipstick',
                    branch: 'b9533adbe0ee5623ebe890a1ecbd429751c24a2d'
gem 'valhammer'

gem 'unicorn', require: false
gem 'god', require: false

source 'https://rails-assets.org' do
  gem 'rails-assets-semantic-ui', '~> 2.0'
  gem 'rails-assets-jquery', '~> 1.11'
  gem 'rails-assets-pickadate', '3.5.6'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.1'
  gem 'rspec-retry'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'aaf-gumboot', git: 'https://github.com/ausaccessfed/aaf-gumboot',
                     branch: 'develop'

  gem 'pry', require: false
  gem 'brakeman', '~> 2.6', require: false
  gem 'simplecov', require: false
  gem 'codeclimate-test-reporter', require: false

  gem 'guard', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-brakeman', require: false
  gem 'guard-unicorn', require: false
  gem 'terminal-notifier-guard', require: false
end
