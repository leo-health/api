require 'airborne'
require 'rails_helper'

describe Leo::V1::Patients do
  let!(:guardian_role){create(:role, :guardian)}
  let!(:patient_role){create(:role, :patient)}
  let!(:family){create(:family_with_members)}
  let(:guardian){family.members.first}
  let!(:session){guardian.sessions.create}

  describe 'GET /api/v1/users/:user_id/patients' do
    def do_request
      get "/api/v1/users/#{guardian.id}/patients", {authentication_token: session.authentication_token}
    end

    it "should return every patients belongs to the guardian" do
      do_request
      expect(response.status).to eq(200)
      expect_json(family.patients)
    end
  end

  describe 'POST /api/v1/users/:user_id/patients' do
    let(:guardian){create(:user, :father)}
    let!(:session){guardian.sessions.create}
    let(:patient_params){FactoryGirl.attributes_for(:patient)}

    def do_request
      patient_params.merge!({authentication_token: session.authentication_token})
      post "/api/v1/users/#{guardian.id}/patients", patient_params, format: :json
    end

    it "should add a patient to the family" do
      do_request
      expect(response.status).to eq(201)
      expect_json('data.patient.first_name', patient_params[:first_name])
      expect_json('data.patient.last_name', patient_params[:last_name])
    end
  end

  describe 'Delete /api/v1/users/:user_id/patients/:id' do
    let!(:patient){family.patients.first}

    def do_request
      delete "/api/v1/users/#{guardian.id}/patients/#{patient.id}", {authentication_token: session.authentication_token}
    end

    it 'should delete the indivial patient record, guardian only' do
      expect{do_request}.to change{ family.patients.count }.from(3).to(2)
      expect(response.status).to eq(200)
    end
  end

  describe 'Put /api/v1/users/:user_id/patients/:id' do
    let!(:patient){family.patients.first}

    def do_request
      put "/api/v1/users/#{guardian.id}/patients/#{patient.id}", {authentication_token: session.authentication_token, email: "new_email@leohealth.com"}
    end

    it 'should update the individual patient record, guardian only' do
      original_email = patient.email
      do_request
      expect(response.status).to eq(200)
      expect{patient.reload}.to change{patient.email}.from(original_email).to("new_email@leohealth.com")
    end
  end
end
