require 'rails_helper'
require 'athena_health_api_helper'

RSpec.describe AthenaHealthApiHelper, type: :helper do
  run_athena = false

  department_id = (ENV["ATHENA_TEST_DEPARTMENT_ID"].to_i <= 0) ? "2" : ENV["ATHENA_TEST_DEPARTMENT_ID"]
  provider_id = (ENV["ATHENA_TEST_PROVIDER_ID"].to_i <= 0) ? "1" : ENV["ATHENA_TEST_PROVIDER_ID"]

  describe "Athena Health Api Connector - " do
    if run_athena
      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new()
    else
      connector = AthenaHealthApiHelper::MockConnector.new(
        appointments: [ 
          {
            :appointmentid => 1, 
            :date => "01/01/2000",
            :starttime => "00:00",
            :appointmenttypeid => 1,
            :departmentid => department_id,
            :reasonid => nil,
            :appointmentstatus => "o",
            :frozenyn => false
          },
          {
            :appointmentid => 1, 
            :date => "01/01/2000",
            :starttime => "00:00",
            :appointmenttypeid => 1,
            :departmentid => department_id,
            :reasonid => nil,
            :appointmentstatus => "f",
            :frozenyn => false
          }           
        ]
      )
    end

    it "get a list of appointment types" do
      res = connector.get_appointment_types()
      Rails.logger.info(res.to_json)
    end

    it "get a list of appointment reasons" do
      res = connector.get_appointment_reasons(departmentid: department_id, providerid: provider_id)
      Rails.logger.info(res.to_json)
    end

    it "get a list of open appointments" do
      res = connector.get_open_appointments(departmentid: department_id, 
        appointmenttypeid: 1, startdate: "01/01/1920", enddate: "01/01/2020")
      #Rails.logger.info(res.to_json)
    end

    it "get a list of booked slots" do
      res = connector.get_booked_appointments(departmentid: department_id, 
        startdate: "01/01/1920", enddate: "01/01/2020")
      Rails.logger.info(res.to_json)
    end

    #don't run modifying tests on athena server
    if !run_athena do
      it "create appointment" do
        res = connector.create_appointment(appointmentdate: "01/01/2020", appointmenttime: "12:00", 
          appointmenttypeid: 1, departmentid: department_id, providerid: provider_id, reasonid: nil)
        expect(res.to_i).to be > 0

        res = connector.get_appointment(appointmentid: res)
        Rails.logger.info(res.to_json)
      end
      
      it "book appointment" do
        res = connector.create_appointment(appointmentdate: "01/01/2020", appointmenttime: "12:00", 
          appointmenttypeid: 1, departmentid: department_id, providerid: provider_id, reasonid: nil)
        expect(res.to_i).to be > 0

        res = connector.book_appointment(appointmentid: res.to_i,
          appointmenttypeid: 1, departmentid: department_id, 
          patientid: 1)

        res = connector.get_appointment(appointmentid: res)
        Rails.logger.info(res.to_json)
      end

      it "cancel booked appointment" do
        res = connector.create_appointment(appointmentdate: "01/01/2020", appointmenttime: "12:00", 
          appointmenttypeid: 1, departmentid: department_id, providerid: provider_id, reasonid: nil)
        expect(res.to_i).to be > 0

        connector.book_appointment(appointmentid: res.to_i,
          appointmenttypeid: 1, departmentid: department_id, 
          patientid: 1)

        connector.cancel_appointment(appointmentid: res, patientid: 1)

        res = connector.get_appointment(appointmentid: res)
        Rails.logger.info(res.to_json)
      end

      it "reschedule booked appointment" do
        res = connector.create_appointment(appointmentdate: "01/01/2020", appointmenttime: "12:00", 
          appointmenttypeid: 1, departmentid: department_id, providerid: provider_id, reasonid: nil)
        expect(res.to_i).to be > 0

        connector.book_appointment(appointmentid: res.to_i,
          appointmenttypeid: 1, departmentid: department_id, 
          patientid: 1)

        res_resch = connector.create_appointment(appointmentdate: "01/01/2020", appointmenttime: "12:00", 
          appointmenttypeid: 1, departmentid: department_id, providerid: provider_id, reasonid: nil)
        expect(res_resch.to_i).to be > 0

        connector.reschedule_appointment(appointmentid: res,
          newappointmentid: res_resch, patientid: 1)

        res = connector.get_appointment(appointmentid: res)
        Rails.logger.info(res.to_json)
      end
    end
  end
end
