# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TodoApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Configure ActiveModelSerializers with the JSON Adapter.
    # By default, this adapter serializes associations only one level deep.
    # Associations are any attribute in a serializer you define with:
    # `belongs_to`, `has_one`, or `has_many`.
    ActiveModelSerializers.config.adapter = :json

    # Generate a `structure.sql` file instead of `schema.rb`.
    # This file contains the schema (but not the data) from the database.
    # Rails loads this file into the test database when we run `rspec`.
    config.active_record.schema_format = :sql

    # We're using RSpec as our testing framework, and FactoryBot
    # to generate data when running our unit tests.
    # Here we tell Rails to also generate specs and factories
    # when running generators for models, controllers, etc.
    config.generators do |g|
      g.fixture_replacement :factory_bot
      g.test_framework      :rspec
    end
  end
end
