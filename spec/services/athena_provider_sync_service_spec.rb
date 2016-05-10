require "rails_helper"
describe AthenaProviderSyncService do
  describe ".sync_open_slots" do

    let(:provider_sync_profile){ create(:provider_sync_profile, athena_id: 1) }

    before do
      @service = AthenaProviderSyncService.new
      @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance
    end

    def do_request
      @service.sync_open_slots provider_sync_profile, Date.new(2015, 12, 25)
    end

    context "no slots exist" do
      it "creates slots" do
        expect(@connector).to receive(:get_open_appointments).and_return([
          AthenaHealthApiHelper::AthenaStruct.new(JSON.parse(%q({
            "date": "12\/26\/2015",
            "appointmentid": "389203",
            "departmentid": "1",
            "appointmenttype": "Test",
            "providerid": "1",
            "starttime": "10:30",
            "duration": "10",
            "appointmenttypeid": "21",
            "reasonid": ["-1"],
            "patientappointmenttypename": "Test",
            "frozen": "true"
          }))),
          AthenaHealthApiHelper::AthenaStruct.new(JSON.parse(%q({
            "date": "12\/27\/2015",
            "appointmentid": "389202",
            "departmentid": "1",
            "appointmenttype": "Test",
            "providerid": "1",
            "starttime": "10:30",
            "duration": "10",
            "appointmenttypeid": "21",
            "reasonid": ["-1"],
            "patientappointmenttypename": "Test"
          })))
        ])
        do_request
        expect(Slot.count).to eq(2)
        expect(Slot.free.count).to eq(1)
      end
    end

    context "slots already exist" do
      before do
        start_datetime = Time.new(2015, 12, 27, 10, 30)
        Slot.create!(
          start_datetime: start_datetime,
          end_datetime: start_datetime + 20.minutes,
          free_busy_type: :free,
          athena_id: 389202,
          provider_sync_profile: provider_sync_profile
        )
      end

      it "calculates duration correctly" do
        expect(Slot.first.duration).to eq(20)
      end

      it "updates slots" do
        expect(Slot.count).to eq(1)
        expect(@connector).to receive(:get_open_appointments).and_return([
          AthenaHealthApiHelper::AthenaStruct.new(JSON.parse(%q({
            "date": "12\/27\/2015",
            "appointmentid": "389202",
            "departmentid": "1",
            "appointmenttype": "Test",
            "providerid": "1",
            "starttime": "10:30",
            "duration": "10",
            "appointmenttypeid": "21",
            "reasonid": ["-1"],
            "patientappointmenttypename": "Test"
          })))
        ])
        do_request
        expect(Slot.count).to eq(1)
        expect(Slot.first.duration).to eq(10)
      end
    end
  end
end
