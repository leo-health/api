source 'https://rubygems.org'

gem 'awesome_print'
gem 'rails', '4.2.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'chronic'               # Clever parsing of dates (also NLP date formats)
gem 'daemons'
gem 'delayed_job_active_record'
gem 'devise'                # Authentication
gem 'cancancan', '~> 1.10'
gem 'paranoia', '~> 2.0'
gem 'goldiloader'
gem 'grape'                 # Our API base
gem 'grape-cancan'
gem 'grape-entity'
gem 'grape-kaminari'
gem 'mandrill_mailer'
gem 'carrierwave-aws'
gem 'carrierwave'
gem 'haml-rails', '~> 0.8'  # For having cleaner view templates
gem 'hashie-forbidden_attributes'
gem 'rack-cors'
gem 'simple_token_authentication', '~> 1.0'
gem 'squeel'
gem 'pg'
gem 'pusher'
gem 'public_activity'
gem 'mini_magick'
gem 'aasm'
gem 'grocer'
gem 'pg_search'
gem 'redis'
gem 'whenever', require: false
gem 'twilio-ruby'
gem 'rspec_junit_formatter', '0.2.2'
gem 'figaro'
gem 'unicorn'
gem 'newrelic_rpm'
gem 'useragent'
gem "delayed_job_web"

group :development, :test do
  gem 'airborne'  # Allow easily testing json responses
  gem 'factory_girl_rails'
  gem 'byebug'
  gem 'quiet_assets'
  gem 'spork'
  gem 'rspec-rails'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'fuubar'
  gem 'rspec_api_documentation'
end

group :development, :develop do
  gem 'raddocs'
end

group :test do
  gem 'shoulda-callback-matchers', '~> 1.1.1'
  gem 'shoulda-matchers'
  gem 'grape-entity-matchers'
  gem 'database_cleaner'
  gem 'pusher-fake'
  gem 'codeclimate-test-reporter'
  gem 'fakeredis'
  gem 'timecop'
end

group :production do
  gem 'rails_12factor'
end

group :production, :develop do
  gem 'health_check'
  gem 'lograge'
end

ruby '2.2.2'
