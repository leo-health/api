require 'airborne'
require 'rails_helper'

describe Leo::V1::Enrollments do
  let!(:guardian){ create(:user) }
  let!(:guardian_session){ guardian.sessions.create }

  describe "POST /api/v1/patient_enrollments" do
    def do_request
      enrollment_params = { authentication_token: guardian_session.authentication_token,
                            first_name: 'Tom',
                            last_name: 'BigTree',
                            sex: 'M',
                            birth_date: 5.years.ago }

      post "/api/v1/patient_enrollments", enrollment_params
    end

    it "should create an patient enrollment record" do
      expect{ do_request }.to change{ Patient.count }.from(0).to(1)
      expect(response.status).to eq(201)
    end
  end

  describe "PUT /api/v1/patient_enrollments/:id" do
    let!(:patient){ create(:patient, family: guardian.family) }

    def do_request
      enrollment_params = { authentication_token: guardian_session.authentication_token,
                            first_name: 'Jack',
                           }
      put "/api/v1/patient_enrollments/#{patient.id}", enrollment_params
    end

    it "should update a patient enrollment" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(Patient.count).to eq(1)
      expect( body[:data][:patient_enrollment] )
    end
  end

  describe "Delete /api/v1/patient_enrollments/:id" do
    let!(:patient){ create(:patient, family: guardian.family) }

    def do_request
      enrollment_params = { authentication_token: guardian_session.authentication_token }
      delete "/api/v1/patient_enrollments/#{patient.id}", enrollment_params
    end

    it "should destroy the patient enrollment" do
      do_request
      expect(response.status).to eq(200)
      expect(Patient.count).to eq(0)
    end
  end
end
