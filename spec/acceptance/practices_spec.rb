require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Practices" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let(:authentication_token){ session.authentication_token }

  let(:practice){
    create(:practice, time_zone: Time.zone.name)
  }

  let!(:staff) {
    [
      create(:user, :clinical, practice: practice),
      create(:user, :clinical_support, practice: practice),
      create(:user, :customer_service, practice: practice)
    ]
  }

  let!(:schedule_exceptions) {
    [
      create(:provider_leave, description: "Seeded holiday"),
      create(:provider_leave, description: "Seeded holiday"),
      create(:provider_leave, description: "Seeded holiday")
    ]
  }

  get "/api/v1/practices" do
    parameter :authentication_token, "Authentication Token", required: true
    let(:raw_post){ params.to_json }

    example "get all practices" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
