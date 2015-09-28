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
      byebug
      expect{ do_request }.to change{ PatientEnrollment.count }.from(0).to(1)
      expect(response.status).to eq(201)
    end
  end
end


# requires :guardian_enrollment_id, type: Integer
# requires :first_name, type: String
# requires :last_name, type: String
# requires :sex, type: String, values: ['M', 'F']
# requires :birth_date, type: Date
# optional :title, type: String
# optional :middle_inital, type: String
# optional :suffix, type: String
