require 'airborne'

describe 'Creating families and managing users when authenticated', trans_off: true do
	before(:each) do 
		create(:user, authentication_token: 'yAZ_3VHjVzt8uoi7uD7z', family_id: 1)
	end

	it 'should allow you to create a parent when not signed in' do
		@post_data = FactoryGirl.attributes_for(:user, :father)
		post '/api/v1/users', @post_data, format: :json
		# print_response
		parsed = JSON.parse(response.body)
		user = parsed["data"]["user"]
		expect(response).to have_http_status(201)
		puts "Users_spec"
		print_response
		expect_json_types({data: {user: {first_name: @post_data[:first_name], last_name: @post_data[:last_name], family_id: 1 }}})
		
	end

	it 'should successfully create a user when you invite another parent to join your family' do
		pending 'Implement inviting another parent'
	end

	it 'should allow you to add children to your family' do
		pending 'Implement adding a child to your family'
	end
end
