source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'chronic'               # Clever parsing of dates (also NLP date formats)
gem 'daemons'
gem 'delayed_job_active_record'
gem 'devise'                # Authentication
gem 'devise_invitable'      # Inviting users
gem 'grape'                 # Our API base
gem 'grape-cancan'
gem 'grape-entity'
gem 'grape-kaminari'
gem 'grape-swagger'					# Document the grape api
gem 'grape-swagger-rails'
gem 'haml-rails', '~> 0.8'  # For having cleaner view templates
gem 'hashie-forbidden_attributes'
gem 'rack-cors'
gem 'rolify'                # Managing user roles
gem 'simple_token_authentication', '~> 1.0'
gem 'squeel'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'pg'

group :development, :test do
  gem 'airborne'  # Allow easily testing json responses
  gem 'factory_girl_rails'
  gem 'awesome_print'
  gem 'byebug'
  gem "parallel_tests"
  gem 'byebug'
  gem 'launchy'
  gem 'letter_opener'
  gem 'letter_opener_web', '~> 1.2.0'
  gem 'quiet_assets'
  gem 'pry'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'spork'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'byebug'
  gem 'rails-footnotes'
  gem 'rails_layout'
  gem 'rails-footnotes'
  gem 'rails_layout'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'grape-entity-matchers'
  gem 'database_cleaner'
end

group :production do
  gem 'rails_12factor'
  gem 'unicorn'
end

ruby '2.2.2'
