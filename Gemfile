source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.0'

gem 'rails', '~> 8.0.2'
gem "sprockets-rails"
gem 'puma', '~> 6.0'
gem 'sass-rails', '~> 6.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.11'
gem 'jquery-rails'
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


group :development, :test do
  gem 'sqlite3', '~> 1.7'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'debug', '>= 1.0.0'
end

group :production do
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.8'
  gem 'faker'
  gem 'foreman'
  gem 'better_errors'
  gem 'binding_of_caller'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Use Redis for Action Cable
gem "redis", "~> 4.0"
