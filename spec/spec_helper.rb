require 'rubygems'
require 'spork'
require 'factory_girl_rails'
require 'mandrill_mailer/offline'
require 'codeclimate-test-reporter'

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
  end
end
