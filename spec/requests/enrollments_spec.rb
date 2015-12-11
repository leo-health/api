require 'airborne'
require 'rails_helper'

describe Leo::V1::Enrollments do
  describe "POST /api/v1/enrollments/invite" do
    let!(:user){ create(:user, :guardian) }
    let(:session){ user.sessions.create }
    let!(:onboarding_group){ create(:onboarding_group)}

    def do_request
      enrollment_params = { email: "wuang@leohealth.com", first_name: "Yellow", last_name: "BigRiver" }
      enrollment_params.merge!(authentication_token: session.authentication_token)
      post "/api/v1/enrollments/invite", enrollment_params
    end

    it "should send a invite to the user" do
      expect{ do_request }.to change{ Delayed::Job.count }.from(2).to(3)
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:onboarding_group].to_sym).to eq(:invited_secondary_parent)
    end
  end

  describe "POST /api/v1/enrollments" do
    def do_request
      enrollment_params = {email: "wuang@leohealth.com", password: "password"}
      post "/api/v1/enrollments", enrollment_params
    end

    it "should create an enrollment record" do
      expect{ do_request }.to change{ Enrollment.count }.from(0).to(1)
      expect(response.status).to eq(201)
    end
  end

  describe "Put /api/v1/enrollments/current" do
    let(:enrollment){ create(:enrollment)}
    let(:serializer){ Leo::Entities::EnrollmentEntity }

    def do_request
      enrollment_params = {first_name: "Jack", last_name: "Cash", authentication_token: enrollment.authentication_token }
      put "/api/v1/enrollments/current", enrollment_params
    end

    it "should update the requested enrollment" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:user].as_json.to_json).to eq(serializer.represent(enrollment.reload).as_json.to_json)
    end
  end
end
