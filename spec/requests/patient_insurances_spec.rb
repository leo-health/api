require 'airborne'
require 'rails_helper'
require 'csv'

describe Leo::V1::PatientInsurances do
  let!(:customer_service){ create(:user, :customer_service) }
  let(:user){ create(:user, :guardian) }
  let!(:session){ user.sessions.create }
  let!(:patient){ create(:patient, family: user.family) }

  describe "GET /api/v1/patients/:id/insurances" do
    let!(:insurances) {
      [ 
        create(:insurance, patient_id: patient.id, primary: "1"), 
        create(:insurance, patient_id: patient.id, primary: "2") 
      ]
    }

    def do_request
      get "/api/v1/patients/#{patient.id}/insurances", { authentication_token: session.authentication_token }, format: :json
    end

    it "should return a list of insurances" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["insurances"].size).to eq(2)
    end
  end
end
