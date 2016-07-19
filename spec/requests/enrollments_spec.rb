require 'airborne'
require 'rails_helper'

describe Leo::V1::Enrollments do
  let(:serializer){ Leo::Entities::UserEntity }
  let!(:user){ create(:user, :guardian)}
  let!(:session){ user.sessions.create }

  describe "POST /api/v1/enrollments/invite" do
    let!(:onboarding_group){ create(:onboarding_group, :invited_secondary_guardian)}
    let(:enrollment_params){{
      email: Faker::Internet.email,
      first_name: Faker::Name::first_name,
      last_name: Faker::Name::last_name,
      authentication_token: session.authentication_token
    }}

    def do_request
      post "/api/v1/enrollments/invite", enrollment_params
    end

    before do
      Timecop.freeze(Time.now)
    end

    after do
      Timecop.return
    end

    it "should send a invite to the user and set invitation_sent_at" do
      expect{ do_request }.to change{ Delayed::Job.count }.by(1)
      expect(response.status).to eq(201)
      expect(User.find_by(email: enrollment_params[:email]).invitation_sent_at).to eq(Time.now)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:email]).to eq(enrollment_params[:email])
      expect(body[:data][:onboarding_group].as_json.to_json).to eq(onboarding_group.as_json.to_json)
    end
  end

  describe "POST /api/v1/enrollments" do
    def do_request
      enrollment_params = {
        email: Faker::Internet.email,
        password: Faker::Internet.password(8),
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
      get "/api/v1/enrollments/current", { authentication_token: session.authentication_token }
    end

    it "should show the requested enrollment" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:user]).to eq(serializer.represent(user.reload).as_json)
    end
  end
end
