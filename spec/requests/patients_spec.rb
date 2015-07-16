require 'airborne'
require 'rails_helper'

describe Leo::V1::Patients do
  let!(:family){create(:family_with_members)}
  let(:guardian){Role.find_by_name("guardian").users.first}
  let!(:session){guardian.sessions.create}

  describe 'GET /api/v1/users/:user_id/patients' do
    def do_request
      get "/api/v1/users/#{guardian.id}/patients", {authentication_token: session.authentication_token}
    end

    it "should return every patients belongs to the guardian" do
      do_request
      byebug
      expect(response.status).to eq(200)
      expect_json(Role.find_by_name('patients').users)
    end
  end

  describe 'POST /api/v1/users/:user_id/patients' do
    let(:guardian){create(:user, :father)}
    let!(:session){guardian.sessions.create}
    let!(patient_params){FactoryGirl.attributes_for(:user, :child)}

    def do_request
      patient_params = patient_params.merge({authentication_token: session.authentication_token})
      post "/api/v1/users/patients", patient_params, format: :json
    end

    it "should add a patient to the family" do
      do_request
      expect(response.status).to eq(201)
      expect_json('data.patient.first_name', patient_params[:first_name])
      expect_json('data.patient.last_name', patient_params[:last_name])
    end
  end

  describe 'Delete /api/v1/users/:user_id/patients/:id' do
    let!(:patient){Role.find_by_name("patient").users.first}

    def do_request
      delete "/api/v1/users/#{guardian.id}/patients/#{patient.id}", {authentication_token: session.authentication_token}
    end

    it 'should delete the indivial patient record, guardian only' do
      expect{do_request}.to_change{ Role.find_by_name("patient").user.count }.from(3).to(2)
      expect(response.status).to eq(201)
    end
  end

  describe 'Put /api/v1/users/:user_id/patients/:id' do
    let!(:patient){Role.find_by_name("patient").users.first}

    def do_request
      delete "/api/v1/users/#{guardian.id}/patients/#{patient_id}", {authentication_token: session.authentication_token, email: "new_email@leohealth.com"}
    end

    it 'should update the individual patient record, guardian only' do
      do_request
      expect(response.status).to eq(201)
      expect_json('data.patient.email', "new_email@leohealth.com")
    end
  end
end
