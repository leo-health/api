require 'airborne'

def print_response
	puts "\nResponse"
	puts "--------"
	puts response.to_a
	if response.status >=400 and response.status < 500
		parsed = JSON.parse(response.body)
		puts "--------"
		msg = parsed["message"]
		if msg.nil? or msg.strip.length == 0
			puts "Body: #{response.body}"
		else
			puts "Error: #{msg}"
		end
	else	
		puts "Header: #{response.header}"
		puts "Body: #{response.body}"
	end
end

describe 'Ensure site is up and running, and basic endpoints are working' do
	it 'should successfully hit /api/v1/' do
		get '/api/v1', format: :json
		expect(response).to have_http_status(200)
		expect_json({data: {message: "Welcome to the Leo API"} })
	end
end

describe 'Ensure no data leaks -' do
	it 'should not let you access /users without being logged in' do
		get '/api/v1/users', format: :json
		expect(response).to have_http_status(403)
	end

	it 'should not let you access /appointments without being logged in' do
		get '/api/v1/appointments', format: :json
		expect(response).to have_http_status(403)
	end

	it 'should let you access /appointments when logged in' do
		# Create a user and set the authentication token
		FactoryGirl.create(:user, :father, authentication_token: 'yAZ_3VHjVzt8uoi7uD7z')
		# Log in as user. Response will return the auth token
		@login_params = { email: 'phil.dunphy@gmail.com', password: 'fake_pass' }
		post '/api/v1/sessions', @login_params, format: :json
		# Use the auth token (which we already know) to make an authenticated request
		@get_params = { access_token: 'yAZ_3VHjVzt8uoi7uD7z'}
		get '/api/v1/users', @get_params, format: :json

		expect(response).to have_http_status(200)
		expect_json_types({data: {users: :array}})
	end

end
