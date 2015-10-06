require 'airborne'
require 'rails_helper'

describe Leo::V1::HealthRecords do

  let(:user){ create(:user, :guardian) }
  let!(:session){ user.sessions.create }
  let!(:patient){ create(:patient, family: user.family) }

  describe "GET /api/v1/patients/:id/vitals/height" do
    let!(:heights) {
      [ 
        create(:vital, :height, patient_id: patient.id), 
        create(:vital, :height, patient_id: patient.id), 
        create(:vital, :height, patient_id: patient.id)
      ]
    }

    def do_request
      get "/api/v1/patients/#{patient.id}/vitals/height", { authentication_token: session.authentication_token, start_date: 10.years.ago.strftime("%m/%d/%Y"), end_date: DateTime.now.strftime("%m/%d/%Y") }, format: :json
    end

    it "should return a list of heights" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["heights"].size).to eq(3)
    end
  end

  describe "GET /api/v1/patients/:id/vitals/weight" do
    let!(:weights) {
      [ 
        create(:vital, :weight, patient_id: patient.id), 
        create(:vital, :weight, patient_id: patient.id), 
        create(:vital, :weight, patient_id: patient.id)
      ]
    }

    def do_request
      get "/api/v1/patients/#{patient.id}/vitals/weight", { authentication_token: session.authentication_token, start_date: 10.years.ago.strftime("%m/%d/%Y"), end_date: DateTime.now.strftime("%m/%d/%Y") }, format: :json
    end

    it "should return a list of weights" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["weights"].size).to eq(3)
    end
  end

  describe "GET /api/v1/patients/:id/allergies" do
    let!(:allergies) {
      [ 
        create(:allergy, patient_id: patient.id), 
        create(:allergy, patient_id: patient.id), 
        create(:allergy, patient_id: patient.id)
      ]
    }

    def do_request
      get "/api/v1/patients/#{patient.id}/allergies", { authentication_token: session.authentication_token }, format: :json
    end

    it "should return a list of allergies" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["allergies"].size).to eq(3)
    end
  end

  describe "GET /api/v1/patients/:id/medications" do
    let!(:medications) {
      [ 
        create(:medication, patient_id: patient.id), 
        create(:medication, patient_id: patient.id), 
        create(:medication, patient_id: patient.id),
        create(:medication, patient_id: patient.id, ended_at: DateTime.now) 
      ]
    }

    def do_request
      get "/api/v1/patients/#{patient.id}/medications", { authentication_token: session.authentication_token }, format: :json
    end

    it "should return a list of medications" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["medications"].size).to eq(3)
    end
  end
end
