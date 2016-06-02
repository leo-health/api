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
      expect{do_request({email: user.email})}.to change{Delayed::Job.count}.by(1)
      expect(response.status).to eq(201)
    end
  end

  describe 'PUT /api/v1/passwords/:token/reset' do
    let!(:user){create(:user, password: "old_password", password_confirmation: "old_password")}

    def do_request(reset_params)
      token = user.send(:set_reset_password_token)
      put "/api/v1/passwords/#{token}/reset", reset_params, format: :json
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
        expect_json("message.error_message", "Password is too short (minimum is 8 characters)" )
      end
    end

    context 'reset with different password and password confirmation' do
      it 'should not reset the password for user' do
        do_request({password: "password1", password_confirmation: "password2"})
        expect(response.status).to eq(422)
        expect_json("message.error_message", "Password confirmation doesn't match Password" )
      end
    end

    context 'reset password period expired' do
      def do_request(reset_params)
        token = user.send(:set_reset_password_token)
        user.update_attributes(reset_password_sent_at: Time.now - 13.hours)
        put "/api/v1/passwords/#{token}/reset", reset_params, format: :json
      end

      it 'should not reset the password for user' do
        do_request({password: "new_password", password_confirmation: "new_password"})
        expect(response.status).to eq(422)
        expect_json("message.error_message", "Reset password period expired")
      end
    end
  end

  describe 'PUT /api/v1/passwords/change_password' do
    let!(:user){create(:user, password: "old_password", password_confirmation: "old_password")}
    let(:session){user.sessions.create}

    context "with valid new password and confirmation" do
      def do_request
        password_params = { authentication_token: session.authentication_token, current_password: "old_password", password: "new_password", password_confirmation: "new_password" }
        put "/api/v1/passwords/change_password", password_params
      end

      it "should change the password for user" do
        expect{ do_request }.to change( Delayed::Job, :count ).by(1)
        expect(response.status).to eq(200)
        expect( user.reload.valid_password?("new_password")).to be true
      end
    end

    context "with unmatched passwords" do
      def do_request
        password_params = { authentication_token: session.authentication_token, current_password: "old_password", password: "new_password", password_confirmation: "new_password_with_typo" }
        put "/api/v1/passwords/change_password", password_params
      end

      it "should not change the password for user" do
        expect{ do_request }.to change( Delayed::Job, :count ).by(0)
        expect(response.status).to eq(422)
        expect_json("message.error_message", "Password confirmation doesn't match Password" )
      end
    end
  end
end
