source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.0'

gem 'rails', '~> 8.0.2'
gem "sprockets-rails"
gem 'puma', '~> 6.0'
gem 'jbuilder', '~> 2.11'
gem "chartkick"
gem 'groupdate'
gem 'pg'
gem 'bcrypt', '~> 3.1.7'
gem 'will_paginate', '~> 4.0'
gem 'bootsnap', '>= 1.16.0', require: false
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem "image_processing", "~> 1.2"
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem "redis", "~> 4.0"

group :development, :test do
  gem 'sqlite3', '~> 1.7'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'debug', '>= 1.0.0'
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
  gem 'shoulda-matchers', '~> 5.3'
  gem 'rails-controller-testing'  
  gem 'capybara'
  gem 'selenium-webdriver', '~> 4.11'
  gem 'webdrivers'
  gem 'simplecov', require: false
  gem 'simplecov-html', require: false
  gem 'rspec_junit_formatter', '~> 0.6', require: false
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.8'
  gem 'foreman'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rubocop', '~> 1.60', require: false
  gem 'rubocop-rails', '~> 2.23', require: false
  gem 'rubocop-rspec', '~> 2.26', require: false
  gem 'rubocop-performance', '~> 1.20', require: false
  gem 'rubocop-capybara', '~> 2.20', require: false
  gem 'rubocop-factory_bot', '~> 2.25', require: false
  gem 'rubocop-rspec_rails', '~> 2.28', require: false
  gem 'brakeman', '~> 6.1', require: false
end

