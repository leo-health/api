require 'rubygems'
require 'spork'
require 'factory_girl_rails'
require 'mandrill_mailer/offline'
require 'codeclimate-test-reporter'
require 'rspec_api_documentation'

CodeClimate::TestReporter.start

Spork.prefork do
  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    config.expect_with :rspec do |expectations|
      expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    end

    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = true
    end

    config.before(:each) do
      FakeSms.messages = []
    end

    config.before(:each) do
      FactoryGirl.create(:appointment_status, :cancelled)
      FactoryGirl.create(:appointment_status, :checked_in)
      FactoryGirl.create(:appointment_status, :checked_out)
      FactoryGirl.create(:appointment_status, :charge_entered)
      FactoryGirl.create(:appointment_status, :future)
      FactoryGirl.create(:appointment_status, :open)
    end
  end
end
