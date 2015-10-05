require 'airborne'
require 'rails_helper'

describe Leo::V1::Users do
  let(:user_params){{ first_name: "first_name",
                      last_name: "last_name",
                      email: "guardian@leohealth.com",
                      password: "password",
                      birth_date: 48.years.ago,
                      sex: "M",
                      phone_number: "1234445555"
  }}

  describe "Get /api/v1/staff" do
    let(:guardian){ create(:user, :guardian) }
    let(:session){ guardian.sessions.create }
    let!(:clinical){ create(:user, :clinical) }
    let(:serializer){ Leo::Entities::UserEntity }

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

  describe "POST /api/v1/sign_up - create user with params" do
    let!(:role){create(:role, :guardian)}

    def do_request
      post "/api/v1/sign_up", user_params, format: :json
    end

    it "should create the user with a role, and return created user along with authentication_token" do
      expect{ do_request }.to change{ User.count }.from(0).to(1)
      expect(response.status).to eq(201)
    end
  end

  describe "POST /api/v1/users - create user from enrollment" do
    let!(:role){create(:role, :guardian)}
    let(:patient_params){[{ patient: {
                              first_name: "Patient",
                              last_name: "Params",
                              birth_date: Time.now,
                              sex: "M" },
                            insurance: { plan_name: 'PPO'}
    }]}

    def do_request
      post "/api/v1/users", {user_params: user_params, patient_params: patient_params}, format: :json
    end

    it "should create the user with a role, and return created user along with authentication_token" do
      expect{ do_request }.to change{ User.count }.from(0).to(1)
      expect(response.status).to eq(201)
      expect( Patient.count ).to eq(1)
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
    let!(:deleted_user){create(:user)}

    def do_request
      delete "/api/v1/users/#{deleted_user.id}", {authentication_token: session.authentication_token}
    end

    context "has the right to delete user" do
      let(:user){create(:user, :super_user)}
      let!(:session){user.sessions.create}

      it "should delete selected user if current user has the right" do
        expect(User.count).to eq(2)
        do_request
        expect(response.status).to eq(200)
        expect(User.count).to eq(1)
      end
    end

    context "does not have the right to delete user" do
      let(:user){create(:user, :financial)}
      let!(:session){user.sessions.create}

      it "should not delete selected user and raise error when user do not have the access right" do
        do_request
        expect(response.status).to eq(403)
        expect(User.count).to eq(2)
      end
    end
  end
end
