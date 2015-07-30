require 'airborne'
require 'rails_helper'
require 'mandrill_mailer/offline'

describe Leo::V1::Passwords do
  describe 'POST /api/v1/passwords/send_reset_email'do
    let!(:user){create(:user)}

    def do_request(reset_params)
      post "/api/v1/passwords/send_reset_email", reset_params, format: :json
    end

    it 'should send the user reset password instruction' do
      expect{do_request({email: user.email})}.to change{MandrillMailer::deliveries.count}.by(1)
      expect(response.status).to eq(201)
    end
  end

  describe 'PUT /api/v1/passwords/reset' do
    let!(:user){create(:user, password: "old_password", password_confirmation: "old_password")}

    before do
      user.update_attributes(reset_password_token: "token", reset_password_sent_at: Time.now)
    end

    def do_request(reset_params)
      put "/api/v1/passwords/#{user.reset_password_token}/reset", reset_params, format: :json
    end

    context 'reset with valid password' do
      it 'should reset the password for user' do
        do_request({password: "new_password", password_confirmation: "new_password"})
        expect(response.status).to eq(200)
        expect( user.reload.valid_password?("new_password")).to be true
      end
    end

    context 'reset with short password(< 8 characters)' do
      it 'should not reset the password for user' do
        do_request({password: "1", password_confirmation: "1"})
        expect(response.status).to eq(422)
        expect_json("data.error_message", "Password need to has at least 8 characters" )
      end
    end

    context 'reset password period expired' do
      before do
        user.update_attributes(reset_password_sent_at: Time.now - 7.hours)
      end

      it 'should not reset the password for user' do
        do_request({password: "new_password", password_confirmation: "new_password"})
        expect(response.status).to eq(422)
        expect_json("data.error_message", "Reset password period expired")
      end
    end
  end
end
