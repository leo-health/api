require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Sessions" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user, password: "password") }

  post "/api/v1/login" do
    parameter :email, "Email", required: true
    parameter :password, "Password", required: true
    parameter :device_token, "Device Token"

    let(:email){ user.email }
    let(:password){ "password" }
    let(:device_token){ "token" }

    let(:raw_post){ params.to_json }

    example "create a session on login" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  delete "/api/v1/logout" do
    parameter :authentication_token, "Authentication Token", required: true

    let!(:session){ user.sessions.create }
    let(:authentication_token){ session.authentication_token }
    let(:raw_post){ params.to_json }

    example "destroy session on logout" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
