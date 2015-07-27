require 'rails_helper'
require 'sync_service_helper'

RSpec.describe SyncServiceHelper, type: :helper do
  department_id = (ENV["ATHENA_TEST_DEPARTMENT_ID"].to_i <= 0) ? "2" : ENV["ATHENA_TEST_DEPARTMENT_ID"]
  provider_id = (ENV["ATHENA_TEST_PROVIDER_ID"].to_i <= 0) ? "1" : ENV["ATHENA_TEST_PROVIDER_ID"]

  describe "Sync Service Helper - " do

    if false

      it "generate initial appointment sync tasks" do
        connector = AthenaHealthApiHelper::MockConnector.new()
        syncer = SyncServiceHelper::Syncer.new(connector)

        #create appointment in leo
        create(:appointment, athena_department_id: department_id)
        SyncTask.destroy_all()

        expect(SyncTask.all.empty?).to eq(true)

        #generate sync task for the appointment
        task = SyncTask.new(sync_type: :scan_appointments, sync_id: 0)
        syncer.process_scan_appointments(task)

        expect(SyncTask.all.empty?).to eq(false)
      end

      it "sync booked leo appointment with missing athena appointment" do
        connector = AthenaHealthApiHelper::MockConnector.new()
        syncer = SyncServiceHelper::Syncer.new(connector)

        #create appointment in leo
        leo_appt = create(:appointment, appointment_status: "f", athena_id: 0, athena_department_id: department_id, 
          athena_provider_id: provider_id, frozenyn: false)
        expect(leo_appt.athena_id).to eq(0)
        SyncTask.destroy_all()

        #generate sync task for the appointment
        task = SyncTask.new(sync_type: :appointment, sync_id: leo_appt.id)
        syncer.process_appointment(task)

        #get updated appointment from leo
        leo_appt = Appointment.find(leo_appt.id)
        Rails.logger.info("leo_appt: #{leo_appt.to_json}")
        expect(leo_appt.athena_id).not_to eq(0)

        #get updated appointment from athena
        athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
        Rails.logger.info("athena_appt: #{athena_appt.to_json}")
        expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
        expect(athena_appt.date).to eq(leo_appt.appointment_date.strftime("%m/%d/%Y"))
        expect(athena_appt.starttime).to eq(leo_appt.appointment_start_time)
        expect(athena_appt.appointmenttypeid).to eq(leo_appt.athena_appointment_type_id)
        expect(athena_appt.departmentid).to eq(leo_appt.athena_department_id)
        expect(athena_appt.providerid).to eq(leo_appt.athena_provider_id)
        expect(athena_appt.frozenyn).to eq(leo_appt.frozenyn)
      end

      it "sync booked leo appointment with open athena appointment" do
        connector = AthenaHealthApiHelper::MockConnector.new(appointments: [ 
            {
              :appointmentid => 1, 
              :date => "01/01/2000",
              :starttime => "00:00",
              :appointmenttypeid => 2,
              :departmentid => department_id,
              :providerid => provider_id,
              :reasonid => nil,
              :appointmentstatus => "o",
              :frozenyn => true
            }         
          ])
        syncer = SyncServiceHelper::Syncer.new(connector)

        #create appointment in leo
        leo_appt = create(:appointment, appointment_status: "f", athena_id: 1, athena_department_id: department_id, 
          athena_provider_id: provider_id, frozenyn: false)
        expect(leo_appt.athena_id).not_to eq(0)
        SyncTask.destroy_all()

        #generate sync task for the appointment
        task = SyncTask.new(sync_type: :appointment, sync_id: leo_appt.id)
        syncer.process_appointment(task)

        #get updated appointment from leo
        leo_appt = Appointment.find(leo_appt.id)
        Rails.logger.info("leo_appt: #{leo_appt.to_json}")
        expect(leo_appt.athena_id).not_to eq(0)

        #get updated appointment from athena
        athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
        Rails.logger.info("athena_appt: #{athena_appt.to_json}")
        expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
  #      expect(athena_appt.date).to eq(leo_appt.appointment_date.strftime("%m/%d/%Y"))
  #      expect(athena_appt.starttime).to eq(leo_appt.appointment_start_time)
        expect(athena_appt.appointmenttypeid).to eq(leo_appt.athena_appointment_type_id)
        expect(athena_appt.departmentid).to eq(leo_appt.athena_department_id)
  #      expect(athena_appt.providerid).to eq(leo_appt.athena_provider_id)
        expect(athena_appt.frozenyn).to eq(leo_appt.frozenyn)
      end
      
      it "sync booked leo appointment with booked athena appointment" do
        connector = AthenaHealthApiHelper::MockConnector.new(appointments: [ 
            {
              :appointmentid => 1, 
              :date => "01/01/2000",
              :starttime => "00:00",
              :appointmenttypeid => 1,
              :departmentid => department_id,
              :providerid => provider_id,
              :reasonid => nil,
              :appointmentstatus => "f",
              :frozenyn => false
            }         
          ])
        syncer = SyncServiceHelper::Syncer.new(connector)

        #create appointment in leo
        leo_appt = create(:appointment, appointment_status: "f", athena_id: 1, athena_department_id: department_id, 
          athena_provider_id: provider_id, frozenyn: true)
        expect(leo_appt.athena_id).not_to eq(0)
        SyncTask.destroy_all()

        #generate sync task for the appointment
        task = SyncTask.new(sync_type: :appointment, sync_id: leo_appt.id)
        syncer.process_appointment(task)

        #get updated appointment from leo
        leo_appt = Appointment.find(leo_appt.id)
        Rails.logger.info("leo_appt: #{leo_appt.to_json}")
        expect(leo_appt.athena_id).not_to eq(0)

        #get updated appointment from athena
        athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
        Rails.logger.info("athena_appt: #{athena_appt.to_json}")
        expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
  #      expect(athena_appt.date).to eq(leo_appt.appointment_date.strftime("%m/%d/%Y"))
  #      expect(athena_appt.starttime).to eq(leo_appt.appointment_start_time)
  #      expect(athena_appt.appointmenttypeid).to eq(leo_appt.athena_appointment_type_id)
  #      expect(athena_appt.departmentid).to eq(leo_appt.athena_department_id)
  #      expect(athena_appt.providerid).to eq(leo_appt.athena_provider_id)
        expect(athena_appt.frozenyn).to eq(leo_appt.frozenyn)
      end

      it "sync booked leo appointment with checked_in athena appointment" do
        connector = AthenaHealthApiHelper::MockConnector.new(appointments: [ 
            {
              :appointmentid => 1, 
              :date => "01/01/2000",
              :starttime => "00:00",
              :appointmenttypeid => 1,
              :departmentid => department_id,
              :providerid => provider_id,
              :reasonid => nil,
              :appointmentstatus => "2",
              :frozenyn => false
            }         
          ])
        syncer = SyncServiceHelper::Syncer.new(connector)

        #create appointment in leo
        leo_appt = create(:appointment, appointment_status: "f", athena_id: 1, athena_department_id: department_id, 
          athena_provider_id: provider_id, frozenyn: true)
        expect(leo_appt.athena_id).not_to eq(0)
        SyncTask.destroy_all()

        #generate sync task for the appointment
        task = SyncTask.new(sync_type: :appointment, sync_id: leo_appt.id)
        syncer.process_appointment(task)

        #get updated appointment from leo
        leo_appt = Appointment.find(leo_appt.id)
        Rails.logger.info("leo_appt: #{leo_appt.to_json}")
        expect(leo_appt.athena_id).not_to eq(0)

        #get updated appointment from athena
        athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
        Rails.logger.info("athena_appt: #{athena_appt.to_json}")
        expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
        expect(leo_appt.appointment_status).to eq("2")
  #      expect(athena_appt.date).to eq(leo_appt.appointment_date.strftime("%m/%d/%Y"))
  #      expect(athena_appt.starttime).to eq(leo_appt.appointment_start_time)
  #      expect(athena_appt.appointmenttypeid).to eq(leo_appt.athena_appointment_type_id)
  #      expect(athena_appt.departmentid).to eq(leo_appt.athena_department_id)
  #      expect(athena_appt.providerid).to eq(leo_appt.athena_provider_id)
  #      expect(athena_appt.frozenyn).to eq(leo_appt.frozenyn)
      end

      it "sync cancelled leo appointment with missing athena appointment" do
        connector = AthenaHealthApiHelper::MockConnector.new()
        syncer = SyncServiceHelper::Syncer.new(connector)

        #create appointment in leo
        leo_appt = create(:appointment, appointment_status: "x", athena_id: 0, athena_department_id: department_id, 
          athena_provider_id: provider_id, frozenyn: false)
        expect(leo_appt.athena_id).to eq(0)
        SyncTask.destroy_all()

        #generate sync task for the appointment
        task = SyncTask.new(sync_type: :appointment, sync_id: leo_appt.id)
        syncer.process_appointment(task)

        #get updated appointment from leo
        leo_appt = Appointment.find(leo_appt.id)
        Rails.logger.info("leo_appt: #{leo_appt.to_json}")
        expect(leo_appt.athena_id).not_to eq(0)

        #get updated appointment from athena
        athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
        Rails.logger.info("athena_appt: #{athena_appt.to_json}")
        expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
        expect(athena_appt.date).to eq(leo_appt.appointment_date.strftime("%m/%d/%Y"))
        expect(athena_appt.starttime).to eq(leo_appt.appointment_start_time)
        expect(athena_appt.appointmenttypeid).to eq(leo_appt.athena_appointment_type_id)
        expect(athena_appt.departmentid).to eq(leo_appt.athena_department_id)
        expect(athena_appt.providerid).to eq(leo_appt.athena_provider_id)
        expect(athena_appt.frozenyn).to eq(leo_appt.frozenyn)
      end

      it "sync cancelled leo appointment with open athena appointment" do
        connector = AthenaHealthApiHelper::MockConnector.new(appointments: [ 
            {
              :appointmentid => 1, 
              :date => "01/01/2000",
              :starttime => "00:00",
              :appointmenttypeid => 2,
              :departmentid => department_id,
              :providerid => provider_id,
              :reasonid => nil,
              :appointmentstatus => "o",
              :frozenyn => true
            }         
          ])
        syncer = SyncServiceHelper::Syncer.new(connector)

        #create appointment in leo
        leo_appt = create(:appointment, appointment_status: "x", athena_id: 1, athena_department_id: department_id, 
          athena_provider_id: provider_id, frozenyn: false)
        expect(leo_appt.athena_id).not_to eq(0)
        SyncTask.destroy_all()

        #generate sync task for the appointment
        task = SyncTask.new(sync_type: :appointment, sync_id: leo_appt.id)
        syncer.process_appointment(task)

        #get updated appointment from leo
        leo_appt = Appointment.find(leo_appt.id)
        Rails.logger.info("leo_appt: #{leo_appt.to_json}")
        expect(leo_appt.athena_id).not_to eq(0)

        #get updated appointment from athena
        athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
        Rails.logger.info("athena_appt: #{athena_appt.to_json}")
        expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
  #      expect(athena_appt.date).to eq(leo_appt.appointment_date.strftime("%m/%d/%Y"))
  #      expect(athena_appt.starttime).to eq(leo_appt.appointment_start_time)
        expect(athena_appt.appointmenttypeid).to eq(leo_appt.athena_appointment_type_id)
        expect(athena_appt.departmentid).to eq(leo_appt.athena_department_id)
  #      expect(athena_appt.providerid).to eq(leo_appt.athena_provider_id)
        expect(athena_appt.frozenyn).to eq(leo_appt.frozenyn)
      end

      it "sync cancelled leo appointment with booked athena appointment" do
        connector = AthenaHealthApiHelper::MockConnector.new(appointments: [ 
            {
              :appointmentid => 1, 
              :date => "01/01/2000",
              :starttime => "00:00",
              :appointmenttypeid => 2,
              :departmentid => department_id,
              :providerid => provider_id,
              :reasonid => nil,
              :appointmentstatus => "f",
              :frozenyn => true
            }         
          ])
        syncer = SyncServiceHelper::Syncer.new(connector)

        #create appointment in leo
        leo_appt = create(:appointment, appointment_status: "x", athena_id: 1, athena_department_id: department_id, 
          athena_provider_id: provider_id, frozenyn: false)
        expect(leo_appt.athena_id).not_to eq(0)
        SyncTask.destroy_all()

        #generate sync task for the appointment
        task = SyncTask.new(sync_type: :appointment, sync_id: leo_appt.id)
        syncer.process_appointment(task)

        #get updated appointment from leo
        leo_appt = Appointment.find(leo_appt.id)
        Rails.logger.info("leo_appt: #{leo_appt.to_json}")
        expect(leo_appt.athena_id).not_to eq(0)

        #get updated appointment from athena
        athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
        Rails.logger.info("athena_appt: #{athena_appt.to_json}")
        expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
  #      expect(athena_appt.date).to eq(leo_appt.appointment_date.strftime("%m/%d/%Y"))
  #      expect(athena_appt.starttime).to eq(leo_appt.appointment_start_time)
  #      expect(athena_appt.appointmenttypeid).to eq(leo_appt.athena_appointment_type_id)
  #      expect(athena_appt.departmentid).to eq(leo_appt.athena_department_id)
  #      expect(athena_appt.providerid).to eq(leo_appt.athena_provider_id)
        expect(athena_appt.frozenyn).to eq(leo_appt.frozenyn)
      end

      it "sync cancelled leo appointment with cancelled athena appointment" do
        connector = AthenaHealthApiHelper::MockConnector.new(appointments: [ 
            {
              :appointmentid => 1, 
              :date => "01/01/2000",
              :starttime => "00:00",
              :appointmenttypeid => 2,
              :departmentid => department_id,
              :providerid => provider_id,
              :reasonid => nil,
              :appointmentstatus => "x",
              :frozenyn => true
            }         
          ])
        syncer = SyncServiceHelper::Syncer.new(connector)

        #create appointment in leo
        leo_appt = create(:appointment, appointment_status: "x", athena_id: 1, athena_department_id: department_id, 
          athena_provider_id: provider_id, frozenyn: false)
        expect(leo_appt.athena_id).not_to eq(0)
        SyncTask.destroy_all()

        #generate sync task for the appointment
        task = SyncTask.new(sync_type: :appointment, sync_id: leo_appt.id)
        syncer.process_appointment(task)

        #get updated appointment from leo
        leo_appt = Appointment.find(leo_appt.id)
        Rails.logger.info("leo_appt: #{leo_appt.to_json}")
        expect(leo_appt.athena_id).not_to eq(0)

        #get updated appointment from athena
        athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
        Rails.logger.info("athena_appt: #{athena_appt.to_json}")
        expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
  #      expect(athena_appt.date).to eq(leo_appt.appointment_date.strftime("%m/%d/%Y"))
  #      expect(athena_appt.starttime).to eq(leo_appt.appointment_start_time)
  #      expect(athena_appt.appointmenttypeid).to eq(leo_appt.athena_appointment_type_id)
  #      expect(athena_appt.departmentid).to eq(leo_appt.athena_department_id)
  #      expect(athena_appt.providerid).to eq(leo_appt.athena_provider_id)
  #      expect(athena_appt.frozenyn).to eq(leo_appt.frozenyn)
      end

      it "sync rescheduled leo appointment with missing athena appointment" do
        connector = AthenaHealthApiHelper::MockConnector.new()
        syncer = SyncServiceHelper::Syncer.new(connector)

        #create appointment in leo
        resched_appt = create(:appointment, appointment_status: "f", athena_id: 0, athena_department_id: department_id, 
          athena_provider_id: provider_id, frozenyn: false)
        leo_appt = create(:appointment, appointment_status: "x", athena_id: 0, athena_department_id: department_id, 
          athena_provider_id: provider_id, frozenyn: false, rescheduled_appointment_id: resched_appt.id)
        expect(leo_appt.athena_id).to eq(0)
        SyncTask.destroy_all()

        #generate sync task for the appointment
        task = SyncTask.new(sync_type: :appointment, sync_id: leo_appt.id)
        syncer.process_appointment(task)

        #get updated appointment from leo
        leo_appt = Appointment.find(leo_appt.id)
        Rails.logger.info("leo_appt: #{leo_appt.to_json}")
        expect(leo_appt.athena_id).not_to eq(0)

        #get updated resched appointment from leo
        resched_leo_appt = Appointment.find(resched_appt.id)
        Rails.logger.info("resched_leo_appt: #{resched_leo_appt.to_json}")
        expect(resched_leo_appt.athena_id).not_to eq(0)

        #get updated appointment from athena
        athena_appt = connector.get_appointment(appointmentid: leo_appt.athena_id)
        Rails.logger.info("athena_appt: #{athena_appt.to_json}")
        expect(athena_appt.appointmentstatus).to eq(leo_appt.appointment_status)
        #expect(athena_appt.date).to eq(leo_appt.appointment_date.strftime("%m/%d/%Y"))
        #expect(athena_appt.starttime).to eq(leo_appt.appointment_start_time)
        #expect(athena_appt.appointmenttypeid).to eq(leo_appt.athena_appointment_type_id)
        #expect(athena_appt.departmentid).to eq(leo_appt.athena_department_id)
        #expect(athena_appt.providerid).to eq(leo_appt.athena_provider_id)
        #expect(athena_appt.frozenyn).to eq(leo_appt.frozenyn)

        #get updated rescheduled appt from athena
        resched_athena_appt = connector.get_appointment(appointmentid: resched_leo_appt.athena_id)
        Rails.logger.info("resched_athena_appt: #{resched_athena_appt.to_json}")
        expect(resched_athena_appt.appointmentstatus).to eq(resched_leo_appt.appointment_status)
        expect(resched_athena_appt.date).to eq(resched_leo_appt.appointment_date.strftime("%m/%d/%Y"))
        expect(resched_athena_appt.starttime).to eq(resched_leo_appt.appointment_start_time)
        expect(resched_athena_appt.appointmenttypeid).to eq(resched_leo_appt.athena_appointment_type_id)
        expect(resched_athena_appt.departmentid).to eq(resched_leo_appt.athena_department_id)
        expect(resched_athena_appt.providerid).to eq(resched_leo_appt.athena_provider_id)
        expect(resched_athena_appt.frozenyn).to eq(resched_leo_appt.frozenyn)
      end
    end
  end
end
