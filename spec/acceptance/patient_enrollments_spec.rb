require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "PatientEnrollments" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:guardian_enrollment){ create(:enrollment) }
  let(:authentication_token){ guardian_enrollment.authentication_token }
  let(:patient_enrollment){ create(:patient_enrollment) }
  let(:id){ patient_enrollment.id }

  post "/api/v1/patient_enrollments" do
    parameter :authentication_token, "Enrollment Token", required: true
    parameter :first_name, "First Name", required: true
    parameter :last_name, "Last Name", required: true
    parameter :sex, "Sex", required: true
    parameter :birth_date, "Birth Date", required: true
    parameter :email, "Email"
    parameter :title, "Title"

    let(:first_name){ "Big" }
    let(:last_name){ "Tree" }
    let(:sex){ "M" }
    let(:birth_date){ Time.now }
    let(:raw_post){ params.to_json }

    example "create a patient enrollment record" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  put "/api/v1/patient_enrollments/:id" do
    parameter :authentication_token, "Enrollment Token", required: true
    parameter :id, "Patient Enrollment Id", required: true
    parameter :first_name, "First Name"
    parameter :last_name, "Last Name"
    parameter :sex, "Sex"
    parameter :birth_date, "Birth Date"
    parameter :email, "Email"
    parameter :title, "Title"

    let(:first_name){ "Big" }
    let(:raw_post){ params.to_json }

    example "update a patient enrollment record" do
      do_request
      expect(response_status).to eq(200)
    end
  end


  delete "/api/v1/patient_enrollments/:id" do
    parameter :authentication_token, "Enrollment Token", required: true
    parameter :id, "Patient Enrollment Id", required: true

    let(:raw_post){ params.to_json }

    example "delete a patient enrollment record" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
