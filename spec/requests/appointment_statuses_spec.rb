require 'airborne'
require 'rails_helper'

describe Leo::V1::AppointmentStatuses do
  describe "GET /api/v1/appointment_statues" do
    let(:user){ create(:user, :guardian) }
    let(:session){ user.sessions.create }

    def do_request
      get '/api/v1/appointment_statuses', { authentication_token: session.authentication_token }
    end

    it "returns all roles" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:appointment_statuses].as_json.to_json).to eq(
        AppointmentStatus.all.as_json.to_json)
    end
  end
end
