require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Enrollments" do
  before do
    create(:practice)
  end

  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let(:authentication_token){ session.authentication_token }

  post "/api/v1/enrollments/invite" do
    parameter :first_name, "First Name", required: true
    parameter :last_name, "Last Name", required: true
    parameter :email, "Email", required: true
    parameter :authentication_token, "Authentication Token", required: true

    let(:first_name){ "Big" }
    let(:last_name){ "Tree" }
    let(:email){ "BigTree@yahoo.com" }
    let!(:onboarding_group){ create(:onboarding_group, :invited_secondary_guardian)}
    let(:raw_post){ params.to_json }

    example "invite a secondary parent" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  post "/api/v1/enrollments" do
    parameter :email, "Email", required: true
    parameter :password, "Password", required: true
    parameter :vendor_id, "Password", required: true

    let(:email){ "BigTree@yahoo.com" }
    let(:password){ "password" }
    let(:vendor_id){"id"}
    let!(:role){ create(:role) }
    let(:raw_post){ params.to_json }

    example "create an enrollment" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  get "/api/v1/enrollments/current" do
    parameter :authentication_token, "Enrollment Token", required: true

    example "find/show an enrollment" do
      explanation "show the enrollment via authentication token(enrollment token)"
      do_request
      expect(response_status).to eq(200)
    end
  end

  put "/api/v1/enrollments/current" do
    parameter :authentication_token, "Enrollment Token", required: true
    parameter :password
    parameter :first_name
    parameter :last_name
    parameter :email
    parameter :phone
    parameter :birth_date
    parameter :sex
    parameter :stripe_customer_id
    parameter :insurance_plan_id

    let(:first_name){ "little" }
    let(:raw_post){ params.to_json }

    example "update an enrollment" do
      explanation "update the enrollment found by authentication token(enrollment token)"
      do_request
      expect(response_status).to eq(200)
    end
  end
end
