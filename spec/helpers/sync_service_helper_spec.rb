require 'rails_helper'
require 'sync_service_helper'

RSpec.describe SyncServiceHelper, type: :helper do
  department_id = ENV["ATHENA_TEST_DEPARTMENT_ID"].empty? ? "1" : ENV["ATHENA_TEST_DEPARTMENT_ID"]

  describe "Sync Service Helper - " do

    it "generate initial appointment sync tasks" do
      connector = AthenaHealthApiHelper::MockConnector.new()
      syncher = SyncServiceHelper::Syncher.new(connector)

      #create appointment in leo
      create(:appointment, athena_department_id: department_id)
      SyncTask.destroy_all()

      expect(SyncTask.all.empty?).to eq(true)

      #generate sync task for the appointment
      task = SyncTask.new(sync_type: :gen_initial_appointment_tasks, sync_source: :leo, sync_id: 0)
      syncher.process_gen_initial_appointment_tasks_task(task)

      expect(SyncTask.all.empty?).to eq(false)
    end

    it "sync open appointment to athena" do
      connector = AthenaHealthApiHelper::MockConnector.new()
      syncher = SyncServiceHelper::Syncher.new(connector)

      #create appointment in leo
      leo_appt = create(:appointment, appointment_status: "o", athena_id: 0, athena_department_id: department_id)
      expect(leo_appt.athena_id).to eq(0)
      SyncTask.destroy_all()

      #generate sync task for the appointment
      task = SyncTask.new(sync_type: :appointment, sync_source: :leo, sync_id: leo_appt.id)
      syncher.process_appointment_task(task)

      #get updated appointment from leo
      leo_appt = Appointment.find(leo_appt.id)
      expect(leo_appt.athena_id).not_to eq(0)

      athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
      expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
    end

    it "sync booked appointment to athena" do
      connector = AthenaHealthApiHelper::MockConnector.new()
      syncher = SyncServiceHelper::Syncher.new(connector)

      #create appointment in leo
      leo_appt = create(:appointment, appointment_status: "f", athena_id: 0, athena_department_id: department_id)
      expect(leo_appt.athena_id).to eq(0)
      SyncTask.destroy_all()

      #generate sync task for the appointment
      task = SyncTask.new(sync_type: :appointment, sync_source: :leo, sync_id: leo_appt.id)
      syncher.process_appointment_task(task)

      #get updated appointment from leo
      leo_appt = Appointment.find(leo_appt.id)
      expect(leo_appt.athena_id).not_to eq(0)

      athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
      expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
    end
    
    it "sync booked appointment to athena" do
      connector = AthenaHealthApiHelper::MockConnector.new()
      syncher = SyncServiceHelper::Syncher.new(connector)

      #create appointment in leo
      leo_appt = create(:appointment, appointment_status: "f", athena_id: 0, athena_department_id: department_id)
      expect(leo_appt.athena_id).to eq(0)
      SyncTask.destroy_all()

      #generate sync task for the appointment
      task = SyncTask.new(sync_type: :appointment, sync_source: :leo, sync_id: leo_appt.id)
      syncher.process_appointment_task(task)

      #get updated appointment from leo
      leo_appt = Appointment.find(leo_appt.id)
      expect(leo_appt.athena_id).not_to eq(0)

      athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
      expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
    end
  end
end
