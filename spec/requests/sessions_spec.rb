require 'airborne'
require 'rails_helper'

describe Leo::V1::Sessions do
  let!(:user){create(:user, password: "password", password_confirmation: "password")}

  describe 'POST /api/v1/login' do
    def do_request(login_params)
      post "/api/v1/login", login_params, format: :json
    end

    context 'user have correct email and password' do
      it 'should create a session for the user and return the session infomation' do
        expect{do_request({email: user.email, password: 'password'})}.to change{Session.count}.from(0).to(1)
        expect(response.status).to eq(201)
      end
    end

    context 'user do not have correct email and password' do
      it 'should not create session and return error message' do
        do_request({email: user.email, password: 'wrong_password'})
        expect(response.status).to eq(422)
        expect(Session.count).to eq(0)
      end
    end

    context 'user is a child' do
      let!(:child){create(:user, :child, password: "password", password_confirmation: "password")}

      it 'should not create session and return errror message' do
        do_request({email: child.email, password: 'password'})
        expect(response.status).to eq(422)
        expect(Session.count).to eq(0)
      end
    end
  end

  describe 'DELETE /api/v1/logout' do
    let!(:session){user.sessions.create}

    def do_request
      delete "/api/v1/logout", logout_params = {authentication_token: session.authentication_token}, format: :json
    end

    it "should set the disabled at entry to soft delete the session" do
      expect{do_request}.to change{Session.count}.from(1).to(0)
      expect(response.status).to eq(200)
      expect(Session.unscoped.count).to eq(1)
    end
  end
end
