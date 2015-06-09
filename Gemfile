source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# gem 'rails_12factor'
gem 'chronic'               # Clever parsing of dates (also NLP date formats)
gem 'daemons'
gem 'delayed_job_active_record'
gem 'devise'                # Authentication 
gem 'devise_invitable'      # Inviting users
gem 'grape'                 # Our API base
gem 'grape-entity'
gem 'grape-kaminari'
gem 'grape-swagger'					# Document the grape api
gem 'grape-swagger-rails'
gem 'haml-rails', '~> 0.8'  # For having cleaner view templates
#gem 'hashie_rails'
gem 'hashie-forbidden_attributes'
gem 'rack-cors'
gem 'rolify'                # Managing user roles
gem 'simple_token_authentication', '~> 1.0'
gem 'squeel'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'airborne'  # Allow easily testing json responses
	gem 'factory_girl_rails'
	#gem 'guard'
  #gem 'guard-rspec'
  ## gem 'guard-cucumber'
  #gem 'guard-livereload'
  #gem 'guard-spork'
  ## gem 'guard-brakeman'
  gem 'launchy'
  gem 'letter_opener'
	gem 'letter_opener_web', '~> 1.2.0'
	gem 'quiet_assets'
  gem 'pry'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'spork'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'sqlite3'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
	# gem 'brakeman'
  gem 'bullet'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rails-footnotes'
  gem 'rails_layout'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :test do 
  # gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
end

group :production do
	# Use Unicorn as the app server
	gem 'pg'
	gem 'rails_12factor'
	gem 'unicorn'
end

ruby '2.2.2'