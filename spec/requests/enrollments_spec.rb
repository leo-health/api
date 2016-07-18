require 'rails_helper'

describe Leo::V1::Enrollments do
  let!(:role){create(:role, :guardian)}
  let(:serializer){ Leo::Entities::UserEntity }
  let!(:enrollment_user){ create(:user, :guardian)}
  let!(:enrollment_session){ enrollment_user.sessions.create }

  describe "POST /api/v1/enrollments/invite" do
    let!(:user){ create(:user, :guardian) }
    let(:session){ user.sessions.create }
    let!(:onboarding_group){ create(:onboarding_group, :invited_secondary_guardian)}

    def do_request
      enrollment_params = {
        email: "wuang@leohealth.com",
        first_name: Faker::Name::first_name,
        last_name: Faker::Name::last_name,
        authentication_token: session.authentication_token
      }

      post "/api/v1/enrollments/invite", enrollment_params
    end

    it "should send a invite to the user" do
      expect{ do_request }.to change{ Delayed::Job.count }.by(1)
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:email]).to eq("wuang@leohealth.com")
      expect(body[:data][:onboarding_group].as_json.to_json).to eq(onboarding_group.as_json.to_json)
    end
  end

  describe "POST /api/v1/enrollments" do
    def do_request
      enrollment_params = {
        email: "wuang@leohealth.com",
        password: "password",
        vendor_id: "vendor_id"
      }

      post "/api/v1/enrollments", enrollment_params
    end

    it "should create an enrollment record" do
      expect{ do_request }.to change{ User.count }.from(1).to(2)
      expect(response.status).to eq(201)
    end
  end

  describe "GET /api/v1/enrollments/current" do
    def do_request
      get "/api/v1/enrollments/current", { authentication_token: enrollment_session.authentication_token }
    end

    it "should show the requested enrollment" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:user]).to eq(serializer.represent(enrollment_user.reload).as_json)
    end
  end
end
