require 'airborne'
require 'rails_helper'

describe Leo::V1::Users do
  let(:user_params){{ first_name: "first_name",
                      last_name: "last_name",
                      email: "guardian@leohealth.com",
                      password: "password",
                      sex: "M",
                      phone: "1234445555",
                      vendor_id: "id"
  }}
  let!(:default_practice) { create(:practice) }
  let(:serializer){ Leo::Entities::UserEntity }

  describe "Get /api/v1/staff" do
    let(:guardian){ create(:user, :guardian) }
    let(:session){ guardian.sessions.create }
    let!(:clinical){ create(:user, :clinical) }

    def do_request
      get "/api/v1/staff", { authentication_token: session.authentication_token }
    end

    it "should return the staff users" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:staff].as_json.to_json).to eq(serializer.represent([clinical]).as_json.to_json)
    end
  end

  describe "Get /api/v1/search_user" do
    let(:serializer){ Leo::Entities::ShortUserEntity }
    let(:user){ create(:user, first_name: "test", last_name: "user") }
    let(:session){ user.sessions.create }

    def do_request
      get "/api/v1/search_user", { authentication_token: session.authentication_token, query: "test" }
    end

    it "should return the user has name matches the query" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:guardians].as_json.to_json).to eq(serializer.represent([user]).as_json.to_json)
    end
  end

  describe "POST /api/v1/users - create user from enrollment" do
    let!(:guardian_role){create(:role, :guardian)}
    let(:enrollment_user){ create(:user, email: "bigtree@gmail.com", password: "password")}
    let(:enrollment_session){ enrollment_user.sessions.create }
    let(:serializer){ Leo::Entities::UserEntity }
    let(:user_params){{ first_name: "first_name",
                        last_name: "last_name",
                        phone: "1234445555" }}

    def do_request
      post "/api/v1/users", user_params.merge!(authentication_token: enrollment_session.authentication_token), format: :json
    end

    it "should create the user with a role, and return created user along with authentication_token" do
      expect{ do_request }.to change{ User.count }.from(0).to(1)
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true)
      expect( body[:data][:user].as_json.to_json ).to eq( serializer.represent( User.first ).as_json.to_json )
    end
  end

  describe "GET /api/v1/users/id" do
    let(:user){create(:user)}
    let!(:session){user.sessions.create}

    def do_request
      get "/api/v1/users/#{user.id}", {authentication_token: session.authentication_token}, format: :json
    end

    it "should show the requested user" do
      do_request
      expect(response.status).to eq(200)
      expect_json('data.user.id', user.id)
    end
  end

  describe "GET /api/v1/users/id" do
    let(:user){create(:user)}
    let!(:session){user.sessions.create}

    def do_request
      get "/api/v1/users", {authentication_token: session.authentication_token}, format: :json
    end

    it "should show the requested user" do
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

  describe "GET /api/v1/users/confirm_email" do
    let(:user){create(:user)}

    before do
      current_time = Time.new(2016, 3, 4, 12, 0, 0, "-05:00")
      Timecop.freeze(current_time)
    end

    after do
      Timecop.return
    end

    def do_request
      get "/api/v1/users/confirm_email", { token: user.confirmation_token }
    end

    it "should confirm the user's account" do
      do_request
      expect(response.status).to eq(301)
      expect(response.header['Location']).to eq("http://localhost:8888/email/success")
      expect(user.reload.confirmed_at).to eq(Time.now)
    end
  end
end
