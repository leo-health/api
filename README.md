[![Circle CI](https://circleci.com/gh/leo-health/api/tree/develop.svg?style=svg)](https://circleci.com/gh/leo-health/api/tree/develop)
# api

This is the core api for the leo-health services.

##RVM
If you are on an previous version of Ruby, be sure to run `rvm upgrade 2.2.0 2.2.2`
Ensure that version 2.2.2 is selected as current (and default) using `rvm list`

## Conventions
1. Using rolify gem for roles.
2. Using Devise gem for authentication
3. Using pundit gem for authorization
4. One user model for all users, with associated models for role-specific details
5. Using 'grape' to model the core API calls
6. Using 'grape-entity' to serialize the models for the API responses
7. Using 'grape-swagger' to produce API documentation


## Project Structure
1. The models are in app/models
2. The api is defined in app/api
3. The entities are also in app/api
4. The tests for the api are in spec/requests


## Testing
1. The tests live at spec/[models, requests, etc]
2. To run the test suite,
2a. First run `rake db:test:prepare` on the command line
2b. Then run `spring rspec`


## Setting Up
1. Prerequisites: rvm, git, rails (via rvm), postgres
2. Clone repository from git
3. Run `rake db:seed` to populate the database with seeds (roles, etc.)
4. Run `rails s` to start the local server
