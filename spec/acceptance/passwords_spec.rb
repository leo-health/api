require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Passwords" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user, password: "password") }

  post "/api/v1/passwords/send_reset_email" do
    parameter :email, "Email", required: true

    let(:email){ user.email }
    let(:raw_post){ params.to_json }

    example "send user reset password instruction email" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  put "/api/v1/passwords/change_password" do
    parameter :current_password, "Current Password", required: true
    parameter :password, "New Password", required: true
    parameter :password_confirmation, "New Password Confirmation", required: true
    parameter :authentication_token, "Authentication Token", required: true

    let(:current_password){ "password" }
    let(:password){ "new_password" }
    let(:password_confirmation){ "new_password" }
    let(:session){ user.sessions.create }
    let(:authentication_token){ session.authentication_token }
    let(:raw_post){ params.to_json }

    example "change user's current password" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  put "/api/v1/passwords/:token/reset" do
    parameter :password, "New Password", required: true
    parameter :password_confirmation, "New Password Confirmation", required: true
    parameter :authentication_token, "Authentication Token", required: true

    let(:password){ "new_password" }
    let(:password_confirmation){ "new_password" }
    let(:token){ user.send(:set_reset_password_token) }
    let(:raw_post){ params.to_json }

    example "reset user's password" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
