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

    example "get all staff" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  post "/api/v1/users" do
    parameter :email, "Email", required: true
    parameter :password, "Password", required: true
    parameter :vendor_id, "Vendor Id", required: true
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
    let(:vendor_id){ "12345" }
    let(:raw_post) { params.to_json }

    example "create a user" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  get "/api/v1/users/:id" do
    parameter :id, "User Id", required: true
    parameter :authentication_token, "Authentication Token", required: true

    let(:raw_post){ params.to_json }

    example "get an individual user" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  put "/api/v1/users/:id" do
    parameter :id, "User Id", required: true
    parameter :authentication_token, "Authentication Token", required: true
    parameter :email, "Email", required: true

    let(:email){ "new_email@yafoo.com" }
    let(:raw_post){ params.to_json }


    example "update an individual user" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
