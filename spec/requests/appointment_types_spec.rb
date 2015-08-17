require 'airborne'
require 'rails_helper'

describe Leo::V1::AppointmentTypes do
  describe "GET /api/v1/appointment_types" do
    let(:user){ create(:user, :guardian) }
    let!(:session){ user.sessions.create }
    let!(:well_visit){ create(:appointment_type, :well_visit) }
    let!(:sick_visit){ create(:appointment_type, :sick_visit) }
    let!(:serializer){ Leo::Entities::AppointmentTypeEntity }

    def do_request
      get '/api/v1/appointment_types', { authentication_token: session.authentication_token }
    end

    it "returns all roles" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:appointment_types].as_json.to_json).to eq(serializer.represent(AppointmentType.all).as_json.to_json)
    end
  end
end
