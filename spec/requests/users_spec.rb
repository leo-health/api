require 'airborne'
require 'rails_helper'

describe Leo::V1::Users do

  describe "POST /api/v1/users" do
    let!(:role){create(:role, :guardian)}
    let!(:user_params){{ first_name: "first_name",
                         last_name: "last_name",
                         email: "test@leohealth.com",
                         password: "password",
                         role_id: role.id,
                         dob: 48.years.ago,
                         sex: "M"
                        }}

    def do_request
      post "/api/v1/users", user_params, format: :json
    end

    it "should create the user with a role, and return created user along with authentication_token" do
      expect{ do_request }.to change{ User.count }.from(0).to(1)
      expect(response.status).to eq(201)
    end
  end

  describe "GET /api/v1/users/id" do
    let(:user){create(:user)}
    let!(:session){user.sessions.create}

    def do_request
      get "/api/v1/users/#{user.id}", {authentication_token: session.authentication_token}, format: :json
    end

    it "should update the user info, email only, for authenticated users" do
      do_request
      expect(response.status).to eq(200)
      expect_json('data.user.id', user.id)
    end
  end

  describe "PUT /api/v1/users/id" do
    let(:user){create(:user)}
    let!(:session){user.sessions.create}
    let!(:email){'new_email@leohealth.com'}

    def do_request
      put "/api/v1/users/#{user.id}", {authentication_token: session.authentication_token, email: email}, format: :json
    end

    it "should update the user info, email only, for authenticated users" do
      original_email = user.email
      do_request
      expect(response.status).to eq(200)
      expect{user.reload.confirm}.to change{user.email}.from(original_email).to(email)
    end
  end

  describe "DELETE /api/v1/users/id" do
    let!(:super_user){create(:role, :super_user)}
    let!(:clinical){create(:role, :clinical)}
    let(:user){create(:user, role: super_user)}
    let!(:session){user.sessions.create}
    let!(:deleted_user){create(:user)}

    def do_request
      delete "/api/v1/users/#{deleted_user.id}", {authentication_token: session.authentication_token}
    end

    it "should delete selected user if current user has admin right" do
      expect(User.count).to eq(2)
      do_request
      expect(response.status).to eq(200)
      expect(User.count).to eq(1)
    end

    it "should not delete selected user and raise error when user do not have the access right" do
      user.add_role :clinical
      do_request
      expect(response.status).to eq(403)
      expect(User.count).to eq(2)
    end
  end
end
