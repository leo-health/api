require "rails_helper"
describe AthenaAppointmentSyncService do
  before do
    @service = AthenaAppointmentSyncService.new
    @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance
  end

  let(:mock_appt) {
    AthenaHealthApiHelper::AthenaStruct.new({
      "appointmentstatus": 'f',
      "appointmenttype": "appointmenttype",
      "providerid": "1",
      "duration": "30",
      "date": Date.tomorrow.strftime("%m/%d/%Y"),
      "starttime": "08:00",
      "patientappointmenttypename": "patientappointmenttypename",
      "appointmenttypeid": "1",
      "departmentid": @provider.practice.athena_id.to_s,
      "appointmentid": "1",
      "patientid": "1"
      })
    }

  describe "sync_appointments" do
    before do
      @practice = create(:practice)
      @practice.update(athena_id: 1)
      @family = create(:family_with_members)
      @family.patients.each_with_index { |patient, index| patient.update(athena_id: index+1) }
      @patient = @family.patients.first
      @future_appointment_status = create(:appointment_status, :future)
      @cancelled_appointment_status = create(:appointment_status, :cancelled)
      @provider = create(:user, :clinical)
      @provider.provider_sync_profile.update(athena_id: 1, athena_department_id: 1)
      @appointment_type = create(:appointment_type, :well_visit, athena_id: 1)
    end

    def do_request
      @service.sync_appointments_for_patient @patient
    end

    describe ".sync_appointments_for_patient" do
      it "sends Athena GET /appointments with patientid" do
        expect(@connector).to receive(:get_booked_appointments).with(hash_including(patientid: @patient.athena_id)).and_return([])
        do_request
      end
    end

    describe ".sync_appointments_for_family" do
      it "sends many Athena GET /appointment with patientid" do
        allow(@connector).to receive(:get_booked_appointments).and_return([])
        expect(@connector).to receive(:get_booked_appointments).exactly(3).times
        @service.sync_appointments_for_family @family
      end
    end

    describe ".sync_appointments_for_practice" do
      it "sends one Athena GET /appointment with departmentid" do
        expect(@connector).to receive(:get_booked_appointments).with(hash_including(departmentid: @practice.athena_id)).and_return([])
        @service.sync_appointments_for_practice @practice
      end
    end

    describe ".sync_appointments" do
      context "athena responds with a booked appointment" do
        context "the appointment does not exist in Leo" do
          before do
            @booked_appt = mock_appt
          end

          it "creates a leo appointment" do
            allow(@connector).to receive(:get_booked_appointments).and_return([@booked_appt])
            do_request
            leo_appt = Appointment.find_by(athena_id: @booked_appt.appointmentid.to_i)
            expect(leo_appt).not_to be_nil
            expect(leo_appt.patient_id).to eq(@patient.id)
          end
        end

        context "the slot is double booked in Athena" do
          before do
            @first_booked_appt = mock_appt
            @second_booked_appt = @first_booked_appt.clone
            @second_booked_appt.appointmentid = "2"
          end

          it "double books in Leo" do
            allow(@connector).to receive(:get_booked_appointments).and_return([@first_booked_appt, @second_booked_appt])
            do_request
            leo_appts = Appointment.where(athena_id: [@first_booked_appt.appointmentid.to_i, @second_booked_appt.appointmentid.to_i])
            expect(leo_appts.count).to be(2)
            expect(leo_appts.pluck(:patient_id)).to eq([@patient.id] * 2)
          end
        end

        context "the patient does not exist in Leo" do
          before do
            @booked_appt = mock_appt
            @booked_appt.patientid = "1234"
          end
          it "creates a leo appointment with nil patient" do
            expect(@connector).to receive(:get_booked_appointments).and_return([@booked_appt])
            do_request
            leo_appt = Appointment.find_by(athena_id: @booked_appt.appointmentid.to_i)
            expect(leo_appt).not_to be_nil
            expect(leo_appt.patient_id).to eq(nil)
          end
        end
      end

      context "athena responds with a cancelled appointment" do
        context "the appointment is booked in Leo" do
          before do
            @leo_booked_appt = create(:appointment, :future)
            @cancelled_appt = mock_appt
            @cancelled_appt.appointmentstatus = "x"
            @leo_booked_appt.update(patient: @patient, athena_id: @cancelled_appt.appointmentid.to_i)
          end

          it "updates the appointment_status" do
            allow(@connector).to receive(:get_booked_appointments).and_return([@cancelled_appt])
            do_request
            leo_appt = Appointment.find_by(athena_id: @cancelled_appt.appointmentid.to_i)
            expect(leo_appt).not_to be_nil
            expect(leo_appt.patient_id).to eq(@patient.id)
          end
        end
      end

    describe ".post_appointment" do
      before do
        @leo_booked_appt = create(:appointment, :future)
        @leo_booked_appt.appointment_type.update(athena_id: 1)
        @leo_booked_appt.update(patient: @patient, provider: @provider, start_datetime: Time.now + 1.day)
      end

      context "booked appointment"
        it "sends a POST /appointment to Athena" do
          expect(@connector).to receive(:get_appointment).and_return(mock_appt)
          expect(@connector).to receive(:create_appointment).and_return(1)
          expect(@connector).to receive(:book_appointment)
          @service.post_appointment @leo_booked_appt
        end

        it "sends a POST cancel appointment to Athena" do
          @leo_booked_appt.update(appointment_status: @cancelled_appointment_status)
          expect(@connector).to receive(:get_appointment).and_return(mock_appt)
          expect(@connector).to receive(:cancel_appointment)
          @service.post_appointment @leo_booked_appt
        end
      end
    end
  end
end










#   describe "after receiving appointments from athena" do
#     let!(:provider) { create(:user, :clinical) }
#     let!(:booked_appt) {
#       AthenaHealthApiHelper::AthenaStruct.new({
#         "appointmentstatus": 'f',
#         "appointmenttype": "appointmenttype",
#         "providerid": "1",
#         "duration": "30",
#         "date": Date.tomorrow.strftime("%m/%d/%Y"),
#         "starttime": "08:00",
#         "patientappointmenttypename": "patientappointmenttypename",
#         "appointmenttypeid": "1",
#         "departmentid": provider.practice.athena_id.to_s,
#         "appointmentid": "1",
#         "patientid": "1"
#       })
#     }
#     let(:family) { create(:family) }
#     let!(:provider_sync_profile) { create(:provider_sync_profile, athena_id: 1, provider: provider) }
#     let!(:appointment_type) { create(:appointment_type, :well_visit, athena_id: 1) }
#
#     it "should create a leo appointment if it doesn't already exist" do
#       patient = create(:patient, athena_id: 1, family_id: family.id)
#       expect(practice).not_to be_nil
#       expect(connector).to receive("get_booked_appointments").and_return([ booked_appt ])
#       appt = Appointment.find_by(athena_id: booked_appt.appointmentid.to_i)
#       expect(appt).not_to be_nil
#       expect(appt.patient_id).to eq(patient.id)
#     end
#
#     it "creates leo when double booked in athena" do
#       patient = create(:patient, athena_id: 1, family_id: family.id)
#       allow(connector).to receive("get_booked_appointments").and_return([ booked_appt ])
#       service.sync_appointments_for_patient patient
#       syncer.process_scan_remote_appointments(SyncTask.new(sync_id: booked_appt.departmentid.to_i))
#       appt = Appointment.find_by(athena_id: booked_appt.appointmentid.to_i)
#       expect(appt).not_to be_nil
#       expect(appt.patient_id).to eq(patient.id)
#
#       second_booked_appt = AthenaHealthApiHelper::AthenaStruct.new({
#           "appointmentstatus": 'f',
#           "appointmenttype": "appointmenttype",
#           "providerid": "1",
#           "duration": "30",
#           "date": Date.tomorrow.strftime("%m/%d/%Y"),
#           "starttime": "08:00",
#           "patientappointmenttypename": "patientappointmenttypename",
#           "appointmenttypeid": "1",
#           "departmentid": provider.practice.athena_id.to_s,
#           "appointmentid": "2",
#           "patientid": "1"
#         })
#
#       expect(connector).to receive("get_booked_appointments").and_return([ second_booked_appt ])
#       syncer.process_scan_remote_appointments(SyncTask.new(sync_id: second_booked_appt.departmentid.to_i))
#       appt = Appointment.find_by(athena_id: second_booked_appt.appointmentid.to_i)
#       expect(appt).not_to be_nil
#       expect(appt.patient_id).to eq(patient.id)
#
#     end
#
#     it "creates leo appointment without patient when missing" do
#       expect(connector).to receive("get_booked_appointments").and_return([ booked_appt ])
#       syncer.process_scan_remote_appointments(SyncTask.new(sync_id: booked_appt.departmentid.to_i))
#       appt = Appointment.find_by(athena_id: booked_appt.appointmentid.to_i)
#       expect(appt).not_to be_nil
#       expect(appt.patient_id).to eq(nil)
#     end
#   end
#
#
# end
