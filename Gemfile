source 'https://rubygems.org'

gem 'rails', '~> 4.2.0'
gem 'sass-rails', '~> 4.0.3'
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
                    branch: 'develop'
gem 'valhammer'

gem 'unicorn', require: false
gem 'god', require: false

source 'https://rails-assets.org' do
  gem 'rails-assets-semantic-ui', '~> 1.0'
  gem 'rails-assets-jquery', '~> 1.11'
  gem 'rails-assets-pickadate', '~> 3.5', '!= 3.5.5'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.1'
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

  gem 'guard', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-brakeman', require: false
  gem 'guard-unicorn', require: false
  gem 'terminal-notifier-guard', require: false
end
