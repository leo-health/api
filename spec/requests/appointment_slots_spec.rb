require 'airborne'
require 'rails_helper'

describe Leo::V1::AppointmentSlots do
  describe "GET /api/v1/appointment_slots" do
    let(:date) { Date.tomorrow }
    let(:appointment_type) { create(:appointment_type, :well_visit, athena_id: 1) }
    let(:user){ create(:user, :guardian) }
    let(:session){ user.sessions.create }

    let(:provider) { create(:provider, athena_id: 1) }
    let!(:schedule) { create(:provider_schedule, athena_provider_id: provider.athena_id) }
    let(:second_provider) { create(:provider, athena_id: 2) }
    let!(:second_schedule) { create(:provider_schedule, athena_provider_id: second_provider.athena_id) }
    let(:third_provider) { create(:provider, athena_id: 3) }
    let!(:third_schedule) { create(:provider_schedule, athena_provider_id: third_provider.athena_id) }

    before do
      current_time = Time.new(2016, 3, 2, 12, 0, 0, "-05:00")
      Timecop.freeze(current_time)

      first_start_datetime = Date.tomorrow + 12.hours
      duration = 10
      @num_slots = 10
      @num_available = 8
      @num_slots.times do |i|
        start_datetime = first_start_datetime + (i*duration).minutes
        end_datetime = start_datetime + duration.minutes
        create(:slot, start_datetime: start_datetime, end_datetime: end_datetime, provider: provider)
        create(:slot, start_datetime: start_datetime, end_datetime: end_datetime, provider: second_provider)
        create(:slot, start_datetime: start_datetime, end_datetime: end_datetime, provider: third_provider)
      end
    end

    after do
      Timecop.return
    end

    context "with only one provider param" do
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
        expect(resp["data"][0]["slots"].size).to eq(@num_available)
      end
    end

    context "with multiple provider params" do
      def do_request
        get "/api/v1/appointment_slots", { authentication_token: session.authentication_token,
                                           start_date: date.strftime("%m/%d/%Y"),
                                           end_date: date.strftime("%m/%d/%Y"),
                                           provider_ids: [provider.id, second_provider.id],
                                           appointment_type_id: appointment_type.id }, format: :json
      end

      it "should return a list of open slots for the given providers" do
        do_request
        expect(response.status).to eq(200)
        resp = JSON.parse(response.body)
        expect(resp["data"][0]["provider_id"]).to eq(provider.id)
        expect(resp["data"][0]["slots"].size).to eq(@num_available)
        expect(resp["data"][1]["provider_id"]).to eq(second_provider.id)
        expect(resp["data"][1]["slots"].size).to eq(@num_available)
      end
    end

    context "with no provider params" do
      def do_request
        get "/api/v1/appointment_slots", { authentication_token: session.authentication_token,
                                           start_date: date.strftime("%m/%d/%Y"),
                                           end_date: date.strftime("%m/%d/%Y"),
                                           appointment_type_id: appointment_type.id }, format: :json
      end

      it "should return a list of open slots for all providers" do
        do_request
        expect(response.status).to eq(200)
        resp = JSON.parse(response.body)
        [provider, second_provider, third_provider].each_with_index do |provider, i|
          expect(resp["data"][i]["provider_id"]).to eq(provider.id)
          expect(resp["data"][i]["slots"].size).to eq(@num_available)
        end
      end
    end
  end
end
