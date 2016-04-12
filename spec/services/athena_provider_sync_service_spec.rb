require "rails_helper"
describe AthenaProviderSyncService do
  describe ".sync_provider_leave" do
    before do
      @service = AthenaProviderSyncService.new
      @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance
    end

    it "creates ProviderLeave" do
      provider_sync_profile = create(:provider_sync_profile, athena_id: 1)
      block_appointment_type = create(:appointment_type, :block, athena_id: 1) # Unused variable - this should probably be a constant, not a table row

      expect(@connector).to receive(:get_open_appointments).and_return(
        [
          AthenaHealthApiHelper::AthenaStruct.new(JSON.parse(%q({
            "date": "10\/30\/2015",
            "appointmentid": "378717",
            "departmentid": "1",
            "appointmenttype": "Block",
            "providerid": "1",
            "starttime": "12:12",
            "duration": "30",
            "appointmenttypeid": "1",
            "reasonid": ["-1"],
            "patientappointmenttypename": "Block"
            })))
          ]
        )

        expect(@connector).to receive(:get_open_appointments).and_return(
          [
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
              ]
            )
            @service.sync_provider_leave provider_sync_profile
            first_provider_leave, second_provider_leave = ProviderLeave.where(athena_provider_id: provider_sync_profile.athena_id).where.not(athena_id: 0)
            expect(first_provider_leave).to_not be_nil
            expect(second_provider_leave).to_not be_nil
            expect(first_provider_leave.start_datetime).to eq(Time.zone.parse("30/10/2015 12:12").to_datetime)
            expect(first_provider_leave.end_datetime).to eq(Time.zone.parse("30/10/2015 12:42").to_datetime)
            expect(second_provider_leave.start_datetime).to eq(Time.zone.parse("26/12/2015 10:30").to_datetime)
            expect(second_provider_leave.end_datetime).to eq(Time.zone.parse("26/12/2015 10:40").to_datetime)
          end
        end
      end
