require 'rubygems'
require 'spork'
require 'factory_girl_rails'
require 'mandrill_mailer/offline'
require 'codeclimate-test-reporter'
require 'rspec_api_documentation'

RspecApiDocumentation.configure do |config|
  config.format = [:json]
  config.curl_host = 'http://localhost:3000'
  config.api_name = "Example App API"
  # config.docs_dir = Rails.root.join("doc", "api")
end

CodeClimate::TestReporter.start

Spork.prefork do
  RSpec.configure do |config|

    config.include FactoryGirl::Syntax::Methods
    # rspec-expectations config goes here. You can use an alternate
    # assertion/expectation library such as wrong or the stdlib/minitest
    # assertions if you prefer.
    config.expect_with :rspec do |expectations|
      # This option will default to `true` in RSpec 4. It makes the `description`
      # and `failure_message` of custom matchers include text for helper methods
      # defined using `chain`, e.g.:
      #     be_bigger_than(2).and_smaller_than(4).description
      #     # => "be bigger than 2 and smaller than 4"
      # ...rather than:
      #     # => "be bigger than 2"
      expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    end

    # rspec-mocks config goes here. You can use an alternate test double
    # library (such as bogus or mocha) by changing the `mock_with` option here.
    config.mock_with :rspec do |mocks|
      # Prevents you from mocking or stubbing a method that does not exist on
      # a real object. This is generally recommended, and will default to
      # `true` in RSpec 4.
      mocks.verify_partial_doubles = true
    end

    config.before(:each) do
      FakeSms.messages = []
    end
  end
end
