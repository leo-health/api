require 'airborne'
require 'rails_helper'

describe Leo::V1::Enrollments do
  describe "POST /api/v1/patient_enrollments" do
    let(:guardian_enrollment){ create(:enrollment) }

    def do_request
      enrollment_params = { guardian_enrollment_id: guardian_enrollment.id,
                            first_name: 'Tom',
                            last_name: 'BigTree',
                            sex: 'M',
                            birth_date: 5.years.ago }

      post "/api/v1/patient_enrollments", enrollment_params
    end

    it "should create an patient enrollment record" do
      expect{ do_request }.to change{ PatientEnrollment.count }.from(0).to(1)
      expect(response.status).to eq(201)
    end
  end
end
