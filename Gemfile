source 'https://rubygems.org'

ruby '2.3.1'

gem 'therubyracer'
gem 'execjs'
gem 'rails', '4.2.6'
gem 'pg'
gem 'active_model_serializers', '~> 0.9.5'
gem 'business_time'
gem 'c2', git: 'https://github.com/18f/c2-api-client-ruby.git'
gem 'chronic'
gem 'clockwork'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'email_validator'
gem 'factory_girl_rails'
gem 'faker'
gem 'foreman'
gem 'hana'
gem 'high_voltage', '~> 3.0.0'
gem 'holidays'
gem 'jquery-rails'
gem 'jquery-rails-cdn'
gem 'kaminari'
gem 'octokit', '~> 4.0'
gem 'omniauth'
gem 'omniauth-github'
gem 'puma'
gem 'rack-cors', require: 'rack/cors'
gem 'redcarpet'
gem 'samwise', '~> 0.4.0'
gem 'sass-rails', '~> 5.0'
gem 'selectize-rails'
gem 'simple_form'
gem 'timecop'
gem 'uglifier'
gem 'validate_url'
gem 'has_secure_token' # this can be removed in Rails 5
gem 'uswds-rails', git: 'https://github.com/18F/uswds-rails-gem.git'
gem 'rest-client'

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem 'codeclimate_batch', require: nil
  gem 'dotenv'
  gem 'db-query-matchers'
  gem 'json-schema'
  gem 'shoulda-matchers'
  gem 'sinatra'
  gem 'webmock'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'cucumber-rails', require: false
  gem 'capybara'
  gem 'poltergeist'
  gem 'byebug'
  gem 'pry'
  gem 'database_cleaner'
  gem 'brakeman', require: false
  gem 'hakiri', require: false
  gem 'dotenv-rails'
  gem 'jasmine'
  gem 'apivore'
end

group :development do
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'rails-erd'
  gem 'rubocop'
  gem 'web-console', '~> 2.0'
end

group :production, :staging do
  gem 'cf-app-utils'
  gem 'rails_12factor'
  gem 'newrelic_rpm'
end
