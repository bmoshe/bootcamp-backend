# frozen_string_literal: true

source 'https://rubygems.org'

gem 'active_model_serializers'
gem 'awesome_print'
gem 'bcrypt'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'oj'
gem 'pg'
gem 'puma'
gem 'pundit', git: 'https://github.com/varvet/pundit.git'
gem 'rack-cors'
gem 'rails', '~> 5.2.0'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development do
  gem 'annotate'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-json_expectations'
end
