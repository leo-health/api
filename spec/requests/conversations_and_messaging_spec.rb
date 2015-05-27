require 'airborne'

describe 'Creating conversations and managing participants when not authenticated', trans_off: true do
	before(:each) do 
		create(:user, authentication_token: 'yAZ_3VHjVzt8uoi7uD7z', family_id: 1)
	# 	FactoryGirl.create(:conversation_with_participants)
	end
	it 'should not allow you to create a conversation when not signed in' do
		post '/api/v1/conversations', format: :json
		expect(response).to have_http_status(403)

		# @login_params = { email: 'danish@leohealth.com', password: 'fake_pass' }
		# post '/api/v1/sessions', @login_params, format: :json
		# # puts "Response.body:"
		# # puts response.body
		# expect(response).to have_http_status(401)
		# expect_json({data: {error_code: 404} })
		# expect_json_types({data: {error_message: :string}})
	end

	it 'should not allow you to access conversations when not signed in' do
		get '/api/v1/conversations', format: :json
		expect(response).to have_http_status(403)
	end
end
describe 'Creating conversations and managing participants when not authenticated', trans_off: true do
	before(:each) do 
		create(:user, authentication_token: 'yAZ_3VHjVzt8uoi7uD7z', family_id: 1)
		create(:family_with_members)

	# 	FactoryGirl.create(:conversation_with_participants)
	end

	it 'should allow creation of a conversation valid parameters when logged in' do
		@login_params = { email: 'danish@leohealth.com', password: 'fake_pass' }
		post '/api/v1/sessions', @login_params, format: :json
		parsed = JSON.parse(response.body)
		expect_json_types({'data': {user: :object}})
		expect_json_types({'data': {user: {id: :integer}}})
		@conv_params = {user_id: parsed["data"]["user"]["id"], child_ids: [Family.all.first.children.first.id]}
		@auth_params = { access_token: parsed["data"]["token"]}
		@post_params = @conv_params.merge(@auth_params)
		post '/api/v1/conversations', @post_params, format: :json
		expect(response).to have_http_status(201)

	end


end