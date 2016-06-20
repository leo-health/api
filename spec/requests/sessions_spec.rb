require 'airborne'
require 'rails_helper'

describe Leo::V1::Sessions do
  let!(:user){ create(:user, password: "password", password_confirmation: "password", onboarding_group: OnboardingGroup.primary_guardian) }

  let(:serializer){ Leo::Entities::UserEntity }

  describe 'POST /api/v1/login' do
    def do_request(login_params)
      post "/api/v1/login", login_params, format: :json
    end

    context 'user has correct email and password' do
      before do
        user.create_onboarding_session
      end

      it 'should create a session for the user and return the session infomation' do
        do_request({ email: user.email, password: 'password' })
        expect(Session.count).to be(1)
        expect(Session.first.onboarding_group).to be_nil
        expect(response.status).to eq(201)
        body = JSON.parse( response.body, symbolize_names: true )
        expect( body[:data][:user].as_json.to_json ).to eq( serializer.represent(user).as_json.to_json )
      end
    end

    context 'member has correct email and password' do
      before do
        user.upgrade!
      end

      it 'should return a member if user is upgraded to member' do
        expect{ do_request({email: user.email, password: 'password' }) }.to change{Session.count}.from(0).to(1)
        expect(response.status).to eq(201)
        body = JSON.parse( response.body, symbolize_names: true )
        expect( body[:data][:user].as_json.to_json ).to eq( serializer.represent(user).as_json.to_json )
      end
    end

    context 'user do not have correct email and password' do
      it 'should not create session and return error message' do
        do_request({ email: user.email, password: 'wrong_password' })
        expect(response.status).to eq(422)
        expect(Session.count).to eq(0)
      end
    end
  end

  describe 'DELETE /api/v1/logout' do
    let!(:session){ user.sessions.create }

    def do_request
      delete "/api/v1/logout", { authentication_token: session.authentication_token }, format: :json
    end

    it "should set the disabled at entry to soft delete the session" do
      expect{ do_request }.to change{Session.count}.from(1).to(0)
      expect(response.status).to eq(200)
      expect(Session.unscoped.count).to eq(1)
    end
  end

  describe "POST /api/v1/provider_login" do
    let!(:user){ create(:user, :clinical, password: "password", password_confirmation: "password") }

    def do_request(login_params)
      post "/api/v1/provider_login", login_params, format: :json
    end

    it "should allow a provider to login" do
      expect{ do_request({ email: user.email, password: 'password' }) }.to change{ Session.count }.from(0).to(1)
      expect(response.status).to eq(201)
      body = JSON.parse( response.body, symbolize_names: true )
      expect( body[:data][:user].as_json.to_json ).to eq( serializer.represent(user).as_json.to_json )
    end
  end
end
