require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Forms" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let(:patient){ create(:patient, family: user.family) }
  let(:authentication_token){ session.authentication_token }

  get "/api/v1/forms/:id" do
    parameter :id, "Form Id", :required => true
    parameter :authentication_token, "Authentication Token", :required => true

    let(:form){ create(:form, patient: patient, submitted_by: user) }
    let(:id){ form.id }
    let(:raw_post){ params.to_json }

    example "get an individual message by id" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
