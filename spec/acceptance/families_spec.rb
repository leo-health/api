require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Families" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  get "/api/v1/family" do
    parameter :authentication_token, 'Authentication Token', required: true

    let(:user){ create(:user, :guardian) }
    let!(:session){ user.sessions.create }
    let!(:patient){ create(:patient, family: user.family) }
    let(:authentication_token){ session.authentication_token }
    let(:raw_post){ params.to_json }

    example "get members of a family" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  post "/api/v1/family/patients" do
    parameter :authentication_token, 'Authentication Token', required: true
    parameter :patients, 'Patients array', required: true

    let!(:patient_params1){
      {
        first_name: "patient_first_name1",
        last_name: "patient_last_name1",
        birth_date: 5.years.ago,
        sex: "M"
      }
    }
    let!(:patient_params2){
      {
        first_name: "patient_first_name2",
        last_name: "patient_last_name2",
        birth_date: 5.years.ago,
        sex: "F"
      }
    }

    let(:user){ create(:user, :guardian) }
    let(:session){ user.sessions.create }
    let!(:authentication_token){ session.authentication_token }
    let!(:patients){ [patient_params1, patient_params2] }
    let(:raw_post){ params.to_json }

    example "updates or creates patients" do
      do_request
      expect(response_status).to eq(201)
    end
  end
end
