require 'airborne'
require 'rails_helper'

describe Leo::V1::AppointmentSlots do

  describe "GET /api/v1/appointment_slots" do
    before do
      create(:appointment_status, :cancelled)
      create(:appointment_status, :checked_in)
      create(:appointment_status, :checked_out)
      create(:appointment_status, :charge_entered)
      create(:appointment_status, :future)
      create(:appointment_status, :open)
    end

    let!(:date) { Date.today}
    let!(:provider) { create(:user, :clinical) }
    let!(:provider_profile) { create(:provider_profile, athena_id: 1, provider_id: provider.id) }
    let!(:appointment_type) { create(:appointment_type, :well_visit, athena_id: 1) }
    let!(:schedule) { create(:provider_schedule, athena_provider_id: provider_profile.athena_id, active: true,
        monday_start_time: "9:00",
        monday_end_time: "17:00",
        tuesday_start_time: "9:00",
        tuesday_end_time: "17:00",
        wednesday_start_time: "9:00",
        wednesday_end_time: "17:00",
        thursday_start_time: "9:00",
        thursday_end_time: "17:00",
        friday_start_time: "9:00",
        friday_end_time: "17:00",
        saturday_start_time: "9:00",
        saturday_end_time: "17:00",
        sunday_start_time: "9:00",
        sunday_end_time: "17:00")
    }
    let!(:additional_availability) { create(:provider_additional_availability, athena_provider_id: provider_profile.athena_id, 
        start_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "17:00").to_s).in_time_zone,
        end_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "20:00").to_s).in_time_zone)
    }
    let!(:leaves) { create(:provider_leave, athena_provider_id: provider_profile.athena_id, 
      start_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "09:00").to_s).in_time_zone, 
      end_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "12:00").to_s).in_time_zone)
    }
    let!(:appointment) { create(:appointment, provider_id: provider.id, appointment_status_id: AppointmentStatus.find_by(status: 'f').id,
      start_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "14:00").to_s).in_time_zone,
      duration: 20)
    }
    let(:user){ create(:user, :guardian) }
    let!(:session){ user.sessions.create }

    def do_request
      get "/api/v1/appointment_slots", { authentication_token: session.authentication_token, start_date: date.strftime("%m/%d/%Y"), end_date: date.strftime("%m/%d/%Y"), provider_id: provider.id, appointment_type_id: appointment_type.id }, format: :json
    end

    it "should return a list of open slots" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"][0]["provider_id"]).to eq(provider.id)
      expect(resp["data"][0]["slots"].size).to eq(15)
    end
  end
end
