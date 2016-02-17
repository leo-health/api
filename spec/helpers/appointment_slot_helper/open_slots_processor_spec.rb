require 'rails_helper'

RSpec.describe AppointmentSlotsHelper, type: :helper do
  describe "OpenSlotsProcessor" do
    let(:provider) { create(:user, :clinical) }
    let(:provider_sync_profile) { provider.create_provider_sync_profile!(athena_id: 2, athena_department_id: 2) }
    let(:future_appointment_status){build(:appointment_status, :future)}
    let(:date){Date.today}
    let(:osp){AppointmentSlotsHelper::OpenSlotsProcessor.new}

    let!(:schedule){create( :provider_schedule,
                            athena_provider_id: provider_sync_profile.athena_id,
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
                            sunday_end_time: "17:00" )}

    let!(:additional_availability){create( :provider_additional_availability, athena_provider_id: provider_sync_profile.athena_id,
                                           start_datetime: DateTime.parse(Time.zone.parse("#{date.inspect} 17:00").to_s).in_time_zone,
                                           end_datetime: DateTime.parse(Time.zone.parse("#{date.inspect} 20:00").to_s).in_time_zone )}

    let!(:leaves){create(:provider_leave, athena_provider_id: provider_sync_profile.athena_id,
                         start_datetime: DateTime.parse(Time.zone.parse("#{date.inspect} 09:00").to_s).in_time_zone,
                         end_datetime: DateTime.parse(Time.zone.parse("#{date.inspect} 12:00").to_s).in_time_zone)}

    let!(:appointment){create(:appointment, provider_id: provider.id, appointment_status: future_appointment_status,
                              start_datetime: DateTime.parse(Time.zone.parse("#{date.inspect} 14:00").to_s).in_time_zone,
                              duration: 20)}

    describe "get_provider_availability" do
      let(:provider_availability){AppointmentSlotsHelper::DiscreteIntervals.new(
          [AppointmentSlotsHelper::Interval.new(osp.to_datetime_str(date, "12:00"), osp.to_datetime_str(date, "14:00")),
           AppointmentSlotsHelper::Interval.new(osp.to_datetime_str(date, "14:20"), osp.to_datetime_str(date, "20:00"))])}

      it "computes availability" do
        expect(osp.get_provider_availability(athena_provider_id: provider_sync_profile.athena_id, date: date)).to eq(provider_availability)
      end
    end

    describe "get_open_slots" do
      let(:open_slots){[
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "12:00").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "13:00").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "14:20").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "15:20").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "16:20").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "17:20").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "18:20").to_s).in_time_zone, 60)
      ]}

      it "returns slots" do
        expect(osp.get_open_slots(athena_provider_id: provider_sync_profile.athena_id, date: date, durations: [ 60 ])).to eq(open_slots)
      end
    end
  end
end
