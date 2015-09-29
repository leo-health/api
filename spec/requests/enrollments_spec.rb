require 'airborne'
require 'rails_helper'

describe Leo::V1::Enrollments do
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

    def do_request
      enrollment_params = {first_name: "Jack", last_name: "Cash", authentication_token: enrollment.authentication_token }
      put "/api/v1/enrollments/current", enrollment_params
    end

    it "should update the requested enrollment" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:enrollment].as_json.to_json).to eq(enrollment.reload.as_json.to_json)
    end
  end
end
