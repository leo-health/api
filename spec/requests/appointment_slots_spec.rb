require 'airborne'
require 'rails_helper'

describe Leo::V1::AppointmentSlots do
  describe "GET /api/v1/appointment_slots" do
    before do
      current_time = Time.new(2016, 3, 2, 12, 0, 0, "-05:00")
      Timecop.freeze(current_time)
    end

    after do
      Timecop.return
    end

    let(:date) { Date.tomorrow }
    let(:provider) { create(:user, :clinical) }
    let(:provider_sync_profile) { create(:provider_sync_profile, athena_id: 1, provider: provider) }
    let!(:appointment_type) { create(:appointment_type, :well_visit, athena_id: 1) }
    let!(:schedule) { create(:provider_schedule, athena_provider_id: provider_sync_profile.athena_id) }
    let!(:additional_availability) { create(:provider_additional_availability,
                                            athena_provider_id: provider_sync_profile.athena_id,
                                            start_datetime: Time.zone.parse(date.inspect + " " + "17:00").to_datetime,
                                            end_datetime: Time.zone.parse(date.inspect + " " + "20:00").to_datetime) }

    let!(:leaves) { create(:provider_leave, athena_provider_id: provider_sync_profile.athena_id,
                           start_datetime: Time.zone.parse(date.inspect + " " + "09:00").to_datetime,
                           end_datetime: Time.zone.parse(date.inspect + " " + "12:00").to_datetime) }

    let!(:appointment) { create(:appointment, :future, provider: provider,
                                start_datetime: Time.zone.parse(date.inspect + " " + "14:00").to_datetime,
                                duration: 20) }

    let(:user){ create(:user, :guardian) }
    let(:session){ user.sessions.create }

    def do_request
      get "/api/v1/appointment_slots", { authentication_token: session.authentication_token,
                                         start_date: date.strftime("%m/%d/%Y"),
                                         end_date: date.strftime("%m/%d/%Y"),
                                         provider_id: provider.id,
                                         appointment_type_id: appointment_type.id }, format: :json
    end

    it "should return a list of open slots" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["data"][0]["provider_id"]).to eq(provider.id)
      expect(resp["data"][0]["slots"].size).to eq(15)
    end
  end
end
