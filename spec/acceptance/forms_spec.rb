require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Forms" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let(:patient){ create(:patient, family: user.family) }
  let(:authentication_token){ session.authentication_token }
  let(:form){ create(:form, patient: patient, submitted_by: user) }

  get "/api/v1/forms/:id" do
    parameter :id, "Form Id", required: true
    parameter :authentication_token, "Authentication Token", required: true

    let(:id){ form.id }
    let(:raw_post){ params.to_json }

    example "get an individual form by id" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  delete "/api/v1/forms/:id" do
    parameter :id, "Form Id", required: true
    parameter :authentication_token, "Authentication Token", required: true

    let(:id){ form.id }
    let(:raw_post){ params.to_json }

    example "delete an individual form by id" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  post "/api/v1/forms" do
    parameter :authentication_token, "Authentication Token", required: true
    parameter :patient_id, "Patient Id", required: true
    parameter :title, "Form Title", required: true
    parameter :image, "Image of the Form", required: true
    parameter :notes, "Note"

    let(:image){ Base64.encode64(open(File.new(Rails.root.join('spec', 'support', 'Zen-Dog1.png'))){|io|io.read}) }
    let(:patient_id){ patient.id }
    let(:title){ 'title of the note' }
    let(:notes){ 'body of the note' }
    let(:raw_post){ params.to_json }

    example "create a form" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  put "/api/v1/forms/:id" do
    parameter :id, "Form Id", required: true
    parameter :authentication_token, "Authentication Token", required: true
    parameter :notes, "Note"
    parameter :patient_id, "Patient Id"
    parameter :title, "Form Title"
    parameter :image, "Image of the Form"
    parameter :status, "Status of the Form, one of [submitted, under review, missing information, complete]"

    let(:id){ form.id }
    let(:notes){ 'body of the note' }
    let(:raw_post){ params.to_json }

    example "update info of a form by id" do
      explanation "require at least one of the optional parameters"
      do_request
      expect(response_status).to eq(200)
    end
  end
end
