[![Code Climate](https://codeclimate.com/repos/560ece1b695680474e006336/badges/8a6d0f411a2cb27cbc93/gpa.svg)](https://codeclimate.com/repos/560ece1b695680474e006336/feed)

[![Test Coverage](https://codeclimate.com/repos/560ece1b695680474e006336/badges/8a6d0f411a2cb27cbc93/coverage.svg)](https://codeclimate.com/repos/560ece1b695680474e006336/coverage)

# api

This is the core api for the leo-health services.

##RVM
If you are on an previous version of Ruby, be sure to run `rvm upgrade 2.2.0 2.2.2`
Ensure that version 2.2.2 is selected as current (and default) using `rvm list`

## Conventions

1. Using Devise gem for authentication
2. Using cancancan gem for authorization
3. One user model for all users, with associated models for role-specific details
4. Using 'grape' to model the core API calls
5. Using 'grape-entity' to serialize the models for the API responses
6. Using 'rspec_api_documentation' to produce API documentation


## Project Structure
1. The models are in app/models
2. The api is defined in app/api
3. The entities are also in app/api
4. The tests for the api are in spec/requests


## Testing
1. The tests live at spec/[models, requests, etc]
2. To run the test suite,
2a. First run `rake db:test:prepare` on the command line
2b. Then run `rspec spec`


## Setting Up
1. Prerequisites: rvm, git, rails (via rvm), postgres
2. Clone repository from git
3. Make sure redis is running, run `redis-server`
4. Run `rake db:setup` to prepare and populate the database with seed data (roles, etc.).
5. Run `rails s` to start the local server

## Troubleshooting
1. If you're getting a `HINT:  Must be superuser to create this extension.` error, you need to change your postgres user priveleges. Log into postgres and run these commands: `postgres=# \du #` to list all users, and then `postgres=# ALTER ROLE user CREATEROLE SUPERUSER;``ALTER ROLE #` to assign user the correct priveleges.
