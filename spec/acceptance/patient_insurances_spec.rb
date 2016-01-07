require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "PatientInsurances" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user, :guardian) }
  let!(:session){ user.sessions.create }
  let!(:patient){ create(:patient, family: user.family) }
  let!(:insurances) {
    [ 
      create(:insurance, patient_id: patient.id, primary: "1"), 
      create(:insurance, patient_id: patient.id, primary: "2") 
    ]
  }

  get "/api/v1/patients/:id/insurances" do
    parameter :authentication_token, :required => true
    parameter :id, "Patient Id", :required => true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:raw_post){ params.to_json }

    example "get all patient insurances" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
