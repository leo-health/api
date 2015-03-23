# api  

This is the core api for the leo-health services.  

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
2. To run the test suite, on the command line run `spring rspec`

## Docker
Instructions for installing Compose
```bash
 curl -L https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
 chmod +x /usr/local/bin/docker-compose
 ```