require 'airborne'
require 'rails_helper'

describe 'Creating families and managing users -', trans_off: true do
	before do
		create(:user, authentication_token: 'yAZ_3VHjVzt8uoi7uD7z')
	end

	it 'should allow you to get a list of roles' do
    create(:role, :parent)
		get '/api/v1/roles', format: :json
		expect_json({data: {roles: [{id: 21, name: "parent"}]}})
	end


	it 'should allow you to create a parent when not signed in' do
		create(:role, :parent)
		@post_data = FactoryGirl.attributes_for(:user, :father)
		@post_data[:role] = :parent
		post '/api/v1/users', @post_data, format: :json
		parsed = JSON.parse(response.body)
		user = parsed["data"]["user"]
		expect(response).to have_http_status(201)
		expect_json({data: 
						{user: 
							{ 	first_name: @post_data[:first_name], 
								last_name: @post_data[:last_name], 
								sex: @post_data[:sex]
							}
						}
					})		
	end

  describe "manage your family when logged in -" do
		before(:each) do
			# Login the existing user and make sure that was successful
			@login_params = { email: 'danish@leohealth.com', password: 'fake_pass' }
			post '/api/v1/sessions', @login_params, format: :json
			parsed = JSON.parse(response.body)
			expect_json_types({'data': {user: :object}})
			expect_json_types({'data': {user: {id: :integer}}})

			# Extract the user id and the auth token
			@user_id = parsed["data"]["user"]["id"]
			@auth_params = { access_token: parsed["data"]["token"]}
		end

		it 'should successfully create a user when you invite another parent to join your family' do
			create(:role, :parent)
			# Set up post params with the parent to be invited and the token
			@invite_params = FactoryGirl.attributes_for(:user, :mother)
			@invite_params[:role] = :parent
			@post_params = @invite_params.merge(@auth_params)

			# Set up the url and make the post request
			url = "/api/v1/users/#{@user_id}/invitations"
			post url, @post_params, format: :json

			# parse the results and make sure they are valid
			parsed = JSON.parse(response.body)
			user = parsed["data"]["user"]
			expect(response).to have_http_status(201)
			expect(user['first_name']).to eq(@invite_params[:first_name])
			expect(user['last_name']).to eq(@invite_params[:last_name])
    end
  end
end

describe 'POST /api/v1/users/id/children' do
  let!(:user){create(:user, authentication_token: 'yAZ_3VHjVzt8uoi7uD7z')}

  def do_request
    @child_params = FactoryGirl.attributes_for(:user, :first_child).merge({access_token: user.authentication_token})
    post "/api/v1/users/#{user.id}/children", @child_params, format: :json
  end

  it "should add a child to the family" do
    do_request
    expect(response.status).to eq(201)
    expect_json('data.user.first_name', @child_params[:first_name])
    expect_json('data.user.last_name', @child_params[:last_name])
  end
end

describe 'GET /api/v1/users/id/children' do
  let!(:family){create(:family_with_members)}

  before do
    @user = Role.find_by_name("parent").users.first
    @user.update_attributes(authentication_token: 'yAZ_3VHjVzt8uoi7uD7z')
  end

  def do_request
    get "/api/v1/users/#{@user.id}/children", {access_token: @user.authentication_token}
  end

  it "should return every children belongs to the user" do
    do_request
    expect(response.status).to eq(200)
    expect_json(Role.find_by_name('child').users)
  end
end
