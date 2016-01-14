require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "AppointmentStatuses" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let!(:cancelled){ create(:appointment_status, :cancelled) }


  get "/api/v1/appointment_statuses" do
    parameter :authentication_token, required: true

    let(:authentication_token){ session.authentication_token }
    let(:raw_post){ params.to_json }

    example "get all appointment status" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
