require 'airborne'
require 'rails_helper'

describe Leo::V1::Roles do
  describe 'POST /api/v1/users/id/patients' do
    let!(:user){create(:user, authentication_token: 'yAZ_3VHjVzt8uoi7uD7z')}

    def do_request
      @child_params = FactoryGirl.attributes_for(:user, :child).merge({authentication_token: user.authentication_token})
      post "/api/v1/users/#{user.id}/patients", @child_params, format: :json
    end

    it "should add a child to the family" do
      do_request
      expect(response.status).to eq(201)
      expect_json('data.user.first_name', @child_params[:first_name])
      expect_json('data.user.last_name', @child_params[:last_name])
    end
  end

  describe 'Delete /api/v1/users/id/patients' do

  end

  describe  do

  end

  describe 'GET /api/v1/users/id/patients' do
    let!(:family){create(:family_with_members)}

    before do
      @user = Role.find_by_name("parent").users.first
      @user.update_attributes(authentication_token: 'yAZ_3VHjVzt8uoi7uD7z')
    end

    def do_request
      get "/api/v1/users/#{@user.id}/patients", {authentication_token: @user.authentication_token}
    end

    it "should return every patients belongs to the guardian" do
      do_request
      expect(response.status).to eq(200)
      expect_json(Role.find_by_name('child').users)
    end
  end
end
