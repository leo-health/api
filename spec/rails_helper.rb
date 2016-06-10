ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'database_cleaner'
require 'pusher-fake/support/rspec'
require 'codeclimate-test-reporter'

CodeClimate::TestReporter.start

ActiveRecord::Migration.maintain_test_schema!

RspecApiDocumentation.configure do |config|
  config.app = Rails.application
  config.disable_dsl_status!
  config.format = [:json]
  config.curl_host = 'http://localhost:3000'
  config.api_name = "Example App API"
end

RSpec.configure do |config|
  config.fail_fast = Rails.env.development?
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
  config.before type: :request do
    DatabaseCleaner.strategy = :truncation
  end

  config.after type: :request  do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean

    if Rails.env.test? || Rails.env.cucumber?
      FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/test", "#{Rails.root}/spec/support/uploads"], { secure: true })
    end
  end

  config.infer_spec_type_from_file_location!
end
