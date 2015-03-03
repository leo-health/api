require 'airborne'
# require 'FactoryGirl'

describe 'user registration' do
	it 'should not allow you to sign in when a user doesn\'t exist' do
		@login_params = { email: 'danish@leohealth.com', password: 'fake_pass' }
		post '/api/v1/sessions', @login_params, format: :json
		# puts "Response.header: "
		# puts response.header
		# puts "Response.body:"
		# puts response.body
		expect(response).to have_http_status(401)
		expect_json({error_code: 404})
		expect_json_types({error_message: :string})
	end

	it 'should allow creation of a user with valid parameters' do
		@user_params = FactoryGirl.attributes_for :user 
		post '/api/v1/users', @user_params, format: :json
		expect(response).to have_http_status(201)
		expect_json({first_name: 'Danish', last_name: 'Munir', email: 'danish@leohealth.com'} )
	end

	it 'should allow you to sign in with for a user with valid credentials' do
	end

	it 'should not allow you to sign in for a user with invalid credentials' do
	end

	it 'should not allow you to create a user with the same email' do
	end
end