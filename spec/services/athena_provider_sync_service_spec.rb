require "rails_helper"
describe AthenaProviderSyncService do
  describe ".sync_provider_leave" do
    before do
      @service = AthenaProviderSyncService.new
      @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance
    end

    it "creates ProviderLeave" do
      provider_sync_profile = create(:provider_sync_profile, athena_id: 1)
      expect(@connector).to receive(:get_open_appointments).and_return([
        AthenaHealthApiHelper::AthenaStruct.new(JSON.parse(%q({
          "date": "12\/26\/2015",
          "appointmentid": "389202",
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
      @service.sync_provider_leave provider_sync_profile
      provider_leave = ProviderLeave.where(athena_provider_id: provider_sync_profile.athena_id).where.not(athena_id: 0).order(:start_datetime)
      expect(provider_leave).to_not be_nil
      expect(provider_leave.start_datetime).to eq(Time.zone.parse("30/10/2015 12:12").to_datetime)
      expect(provider_leave.end_datetime).to eq(Time.zone.parse("30/10/2015 12:42").to_datetime)
    end
  end
end
