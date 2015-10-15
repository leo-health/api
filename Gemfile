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
gem 'devise_invitable'      # Inviting users
gem 'cancancan', '~> 1.10'
gem "paranoia", "~> 2.0"
gem 'grape'                 # Our API base
gem 'grape-cancan'
gem 'grape-entity'
gem 'grape-kaminari'
gem 'grape-swagger'					# Document the grape api
gem 'grape-swagger-rails'
gem 'mandrill_mailer'
gem 'carrierwave'
gem 'haml-rails', '~> 0.8'  # For having cleaner view templates
gem 'hashie-forbidden_attributes'
gem 'rack-cors'
gem 'simple_token_authentication', '~> 1.0'
gem 'squeel'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'pg'
gem 'pusher'
gem 'public_activity'
gem "mini_magick"
gem 'state_machines'
gem 'aasm'
gem 'grocer'

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
end

group :development do
  gem 'bullet'
  gem 'rails-footnotes'
  gem 'rails_layout'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'shoulda-callback-matchers', '~> 1.1.1'
  gem 'shoulda-matchers'
  gem 'grape-entity-matchers'
  gem 'database_cleaner'
  gem 'pusher-fake'
  gem 'codeclimate-test-reporter'
end

group :production do
  gem 'rails_12factor'
  gem 'unicorn'
end

ruby '2.2.2'
