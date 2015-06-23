require 'airborne'
# require 'FactoryGirl'

describe 'User registration & login when a user doesn\'t exist -', trans_off: true do
	it 'should not allow you to sign in when a user doesn\'t exist' do
		@login_params = { email: 'danish@leohealth.com', password: 'fake_pass' }
		post '/api/v1/sessions', @login_params, format: :json
		# puts "Response.body:"
		# puts response.body
		expect(response).to have_http_status(401)
		expect_json({data: {error_code: 404} })
		expect_json_types({data: {error_message: :string}})
	end

	it 'should allow creation of a user with valid parameters' do
		create(:role, :parent)
		@user_params = FactoryGirl.attributes_for :user 
		@user_params[:role] = :parent
		post '/api/v1/users', @user_params, format: :json
		expect(response).to have_http_status(201)
		expect_json({data: {user: {first_name: 'Danish', last_name: 'Munir', email: 'danish@leohealth.com'} }})
	end
end

describe 'User registration & login (when a user exists) -', trans_off: true do
	before(:each) do 
		FactoryGirl.create(:user)
	end
	it 'should allow you to sign in for a user with valid credentials' do
		@login_params = { email: 'danish@leohealth.com', password: 'fake_pass' }
		post '/api/v1/sessions', @login_params, format: :json
		expect(response).to have_http_status(201)
		expect_json({status: 'ok'})
		expect_json_types({data: {token: :string}})
	end

	it 'should not allow you to sign in for a user with invalid credentials' do
		@login_params = { email: 'danish@leohealth.com' }
		post '/api/v1/sessions', @login_params, format: :json
		expect(response).to have_http_status(422)
		expect_json({status: 'error'})
	end

	it 'should not allow you to create a user with the same email' do
		create(:role, :parent)
		@user_params = FactoryGirl.attributes_for :user 
		@user_params[:role] = :parent
		post '/api/v1/users', @user_params, format: :json
		expect(response).to have_http_status(422)
		expect_json({status: 'error'})
	end

	it 'should let you request a password reset' do
		@login_params = { email: 'danish@leohealth.com' }
		post '/api/v1/sessions/password', @login_params, format: :json
		expect(response).to have_http_status(201)
		expect_json({status: 'ok'})
	end

	it 'should let you request a passowrd reset even when a user doesn\'t exist' do
		@login_params = { email: 'dtmunir@gmail.com' }
		post '/api/v1/sessions/password', @login_params, format: :json
		expect(response).to have_http_status(201)
		expect_json({status: 'ok'})
	end

	it 'should not let a child user log in' do
		create(:user, :first_child)
		@login_params = FactoryGirl.attributes_for(:user, :first_child)
		post '/api/v1/sessions', @login_params, format: :json 
		expect(response).to have_http_status(401)
		expect_json({status: 'fail'})
	end
end
