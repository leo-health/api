require 'airborne'
require 'rails_helper'

describe Leo::V1::AppointmentSlots do

  describe "GET /api/v1/appointment_slots" do
    let!(:provider_id) { 1 }
    let!(:date) { Date.today}
    let!(:provider) { FactoryGirl.create(:user, :clinical) }
    let!(:appointment_type) { FactoryGirl.create(:appointment_type, :well_visit, athena_id: 1) }

    before do
      schedule = create(:provider_schedule, athena_provider_id: 1, active: true,
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

      additional_availability = create(:provider_additional_availability, athena_provider_id: 1, 
        start_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "17:00").to_s).in_time_zone,
        end_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "20:00").to_s).in_time_zone)

      leaves = create(:provider_leave, athena_provider_id: 1, 
        start_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "09:00").to_s).in_time_zone, 
        end_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "12:00").to_s).in_time_zone)

      appointment = create(:appointment, provider_id: 1,
        start_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "14:00").to_s).in_time_zone,
        duration: 20)

      provider_profile = FactoryGirl.create(:provider_profile, athena_id: 1, provider_id: provider.id)

      appointment_type = FactoryGirl.create(:appointment_type, :well_visit, athena_id: 1)
    end

    def do_request
      get "/api/v1/appointment_slots", { start_date: date, end_date: date, provider_id: provider.id, appointment_type: appointment_type.id }, format: :json
    end

    it "should return a list of open slots" do
      do_request
      expect(response.status).to eq(200)
    end
  end

end
