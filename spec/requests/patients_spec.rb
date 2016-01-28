require 'airborne'
require 'rails_helper'

describe Leo::V1::Patients do
  let!(:bot){ create(:user, :bot)}
  let!(:customer_service){ create(:user, :customer_service) }
  let(:family){create(:family)}
  let(:guardian){create(:user, family: family)}
  let(:session){guardian.sessions.create}
  let!(:patient){create(:patient, family: family)}
  let!(:avatar){create(:avatar, owner: family.patients.first)}
  let(:serializer){ Leo::Entities::PatientEntity }

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
      body = JSON.parse(response.body, symbolize_names: true )
      patient_id = body[:data][:patient][:id]
      expect(body[:data][:patient].as_json.to_json).to eq(serializer.represent(Patient.find(patient_id)).as_json.to_json)
    end
  end

  describe 'Delete /api/v1/patients/:id' do
    def do_request
      delete "/api/v1/patients/#{patient.id}", {authentication_token: session.authentication_token}
    end

    it 'should delete the indivial patient record, guardian only' do
      expect{do_request}.to change{ family.patients.count }.from(1).to(0)
      expect(response.status).to eq(200)
    end
  end

  describe 'Put /api/v1/patients/:id' do
    let(:new_email){ "new_email@leohealth.com" }

    def do_request
      put "/api/v1/patients/#{patient.id}", {authentication_token: session.authentication_token, email: new_email}
    end

    it 'should update the individual patient record, guardian only' do
      original_email = patient.email
      do_request
      expect(response.status).to eq(200)
      expect{patient.reload}.to change{patient.email}.from(original_email).to(new_email)
    end
  end

  describe "Get /api/v1/patients/:id" do
    def do_request
      get "/api/v1/patients/#{patient.id}", {authentication_token: session.authentication_token}
    end

    it 'should show the patient' do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:patient].as_json.to_json).to eq(serializer.represent(patient).as_json.to_json)
    end
  end

  describe "Get /api/v1/patients" do
    def do_request
      get "/api/v1/patients", {authentication_token: session.authentication_token}
    end

    it 'should show the patients' do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:patients].as_json.to_json).to eq(serializer.represent(family.patients).as_json.to_json)
    end
  end
end
