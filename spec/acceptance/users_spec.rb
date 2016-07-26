require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Users" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let!(:default_practice) { create(:practice) }
  let!(:role){create(:role, :guardian)}
  let(:user){create(:user)}
  let(:session){user.sessions.create}
  let(:id){ user.id }
  let(:authentication_token){ session.authentication_token }

  get "/api/v1/staff" do
    parameter :authentication_token, "Authentication Token", required: true

    let!(:clinical){ create(:user, :clinical) }
    let(:raw_post){ params.to_json }

    example "return all the staff" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/search_user" do
    parameter :authentication_token, "Authentication Token", required: true
    parameter :query, "Name of the User to be Searched", required: true

    let(:query){ 'Firstname' }
    let(:raw_post){ params.to_json }

    before do
      user.update_attributes(first_name: query)
    end

    example "return users with matched names" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  put "/api/v1/convert_user" do
    parameter :invitation_token, "Invitation Token", required: true
    parameter :password, "Password", required: true
    parameter :first_name, "First Name"
    parameter :last_name, "Last Name"
    parameter :phone, "Phone"

    let(:invitation_token){ 'invitation_token' }
    let(:password){ 'password' }
    let(:first_name){ 'Firstname' }
    let(:invited_onboarding_group){ create(:onboarding_group, :invited_secondary_guardian) }
    let!(:invited_user){ create(:user, :incomplete, invitation_token: invitation_token, family: user.family, onboarding_group: invited_onboarding_group)}
    let(:raw_post){ params.to_json }

    example "convert invited or exempted guardian to completed guardian" do
      explanation "To convert user, need to pass one of first_name, last_name, phone, password as params"
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/confirm_email" do
    parameter :token, "Token", required: true

    let(:token){ authentication_token }
    let(:raw_post){ params.to_json }

    example "confirm user's email address" do
      do_request
      expect(response_status).to eq(301)
    end
  end

  put "/api/v1/confirm_secondary_guardian" do
    parameter :invitation_token, "Invitation Token", required: true

    let(:invitation_token){ 'invitation_token' }
    let(:invited_onboarding_group){ create(:onboarding_group, :invited_secondary_guardian) }
    let!(:invited_user){ create(:user, :incomplete, invitation_token: invitation_token, family: user.family, onboarding_group: invited_onboarding_group)}
    let(:raw_post){ params.to_json }

    example "confirm secondary guardian account" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  post "/api/v1/users" do
    parameter :email, "Email", required: true
    parameter :password, "Password", required: true
    parameter :vendor_id, "Vendor Id"
    parameter :first_name, "First Name"
    parameter :last_name, "Last Name"
    parameter :phone, "Phone"
    parameter :sex, "Sex"
    parameter :device_type, "Device Type"
    parameter :os_version, "Os Version"
    parameter :platform, "Platform"
    parameter :client_version, "Client Version"
    parameter :device_token, "Device Token"

    let(:email){ "bigtree@yahoo.com" }
    let(:password){ "password" }
    let(:raw_post) { params.to_json }

    example "create a user" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  put "/api/v1/users" do
    parameter :authentication_token, "Authentication Token", required: true
    parameter :first_name, "First Name"
    parameter :last_name, "Last Name"
    parameter :phone, "Phone"

    let(:first_name){ "Firstname" }
    let(:raw_post){ params.to_json }


    example "DEPRECATED: update an individual user" do
      explanation "DEPRECATED: To convert user, need to pass one of first_name, last_name, phone as params"
      do_request
      expect(response_status).to eq(200)
    end
  end

  put "/api/v1/users/current" do
    parameter :authentication_token, "Authentication Token", required: true
    parameter :first_name, "First Name"
    parameter :last_name, "Last Name"
    parameter :phone, "Phone"

    let(:first_name){ "Firstname" }
    let(:raw_post){ params.to_json }

    example " update current user" do
      explanation "need to pass one of first_name, last_name, phone as params"
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/users/current" do
    parameter :authentication_token, "Authentication Token", required: true

    let(:raw_post){ params.to_json }

    example "get the logged in user" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
