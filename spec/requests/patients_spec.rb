require 'airborne'
require 'rails_helper'

describe Leo::V1::Patients do
  let!(:guardian_role){create(:role, :guardian)}
  let!(:patient_role){create(:role, :patient)}
  let(:family){create(:family_with_members)}
  let!(:guardian){family.reload.members.first}
  let!(:session){guardian.sessions.create}

  describe 'POST /api/v1/patients' do
    let(:patient_params){{first_name: "patient_first_name",
                          last_name: "patient_last_name",
                          birth_date: 5.years.ago,
                          sex: "M",
                        }}

    def do_request
      patient_params.merge!({authentication_token: session.authentication_token})
      post "/api/v1/patients", patient_params, format: :json
    end

    it "should add a patient to the family" do
      do_request
      expect(response.status).to eq(201)
      expect_json('data.patient.first_name', patient_params[:first_name])
      expect_json('data.patient.family_id', guardian.family_id)
    end
  end

  describe 'Delete /api/v1/patients/:id' do
    let!(:patient){family.patients.first}

    def do_request
      delete "/api/v1/patients/#{patient.id}", {authentication_token: session.authentication_token}
    end

    it 'should delete the indivial patient record, guardian only' do
      expect{do_request}.to change{ family.patients.count }.from(3).to(2)
      expect(response.status).to eq(200)
    end
  end

  describe 'Put /api/v1/patients/:id' do
    let!(:patient){family.patients.first}

    def do_request
      put "/api/v1/patients/#{patient.id}", {authentication_token: session.authentication_token, email: "new_email@leohealth.com"}
    end

    it 'should update the individual patient record, guardian only' do
      original_email = patient.email
      do_request
      expect(response.status).to eq(200)
      expect{patient.reload}.to change{patient.email}.from(original_email).to("new_email@leohealth.com")
    end
  end

  describe "Get /api/v1/patients/:id" do
    let(:patient){family.patients.first}
    let!(:avatar){create(:avatar, owner: family.patients.first)}
    let(:serializer){ Leo::Entities::PatientEntity }

    def do_request
      get "/api/v1/patients/#{patient.id}", {authentication_token: session.authentication_token, avatar_size: "primary_3x"}
    end

    it 'should show the patient' do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:patient].as_json.to_json).to eq(serializer.represent(patient.reload, {avatar_size: "primary_3x"}).as_json.to_json)
    end
  end

  describe "Get /api/v1/patients" do
    let(:patient){family.patients.first}
    let!(:avatar){create(:avatar, owner: family.patients.first)}
    let(:serializer){ Leo::Entities::PatientEntity }

    def do_request
      get "/api/v1/patients", {authentication_token: session.authentication_token, avatar_size: "primary_3x"}
    end

    it 'should show the patients' do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:patients].as_json.to_json).to eq(serializer.represent(family.patients, {avatar_size: "primary_3x"}).as_json.to_json)
    end
  end
end
