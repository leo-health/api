require 'airborne'
require 'rails_helper'

describe Leo::V1::Users do

  describe "POST /api/v1/users" do
    def do_request
      post "/api/v1/users", user_params = FactoryGirl.attributes_for(:user, :father), format: :json
    end

    it "should create the user with a role, and return created user along with auth_token" do
      do_request
      expect(response.status).to eq(200)
      byebug
    end
  end

  describe "PUT /api/v1/users/id" do
    let!(:user){create(:user, authentication_token: 'yAZ_3VHjVzt8uoi7uD7z')}
    let!(:email){"new_email@leohealth.com"}

    def do_request
      put "/api/v1/users/#{user.id}", {access_token: "yAZ_3VHjVzt8uoi7uD7z", email: email}, format: :json
    end

    it "should update the user info, email only, for authenticated users" do
      do_request
      expect(response.status).to eq(200)
      expect_json('data.user.email', email)
    end
  end

  describe "DELETE /api/v1/users/id" do
    let!(:user){create(:user, authentication_token: "yAZ_3VHjVzt8uoi7uD7z")}
    let!(:deleted_user){create(:user)}
    let!(:admin){create(:role, :admin)}

    before do
      user.add_role :admin
    end

    def do_request
      delete "/api/v1/users/#{deleted_user.id}", {access_token: user.authentication_token}
    end

    it "should delete selected user if current user has admin right" do
      expect(User.count).to eq(2)
      do_request
      expect(response.status).to eq(200)
      expect(User.count).to eq(1)
    end

    it "should not delete selected user and raise error when user do not have the access right" do
      user.roles.destroy_all
      do_request
      expect(response.status).to eq(422)
      expect(User.count).to eq(2)
    end
  end
end



describe 'POST /api/v1/users/id/children' do
  let!(:user){create(:user, authentication_token: 'yAZ_3VHjVzt8uoi7uD7z')}

  def do_request
    @child_params = FactoryGirl.attributes_for(:user, :child).merge({access_token: user.authentication_token})
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
