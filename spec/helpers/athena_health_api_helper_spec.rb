require 'rails_helper'
require 'athena_health_api_helper'

RSpec.describe AthenaHealthApiHelper, type: :helper do
  run_athena = true

  department_id = ENV["ATHENA_TEST_DEPARTMENT_ID"].empty? ? "1" : ENV["ATHENA_TEST_DEPARTMENT_ID"]
  provider_id = ENV["ATHENA_TEST_PROVIDER_ID"].empty? ? "1" : ENV["ATHENA_TEST_PROVIDER_ID"]

  if run_athena
    describe "Athena Health Api Connector - " do

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new()

      it "get a list of appointment types" do
        res = connector.get_appointment_types()
        Rails.logger.info(res.to_json)
        expect(res.empty?).to eq(false)
      end

      it "get a list of appointment reasons" do
        res = connector.get_appointment_reasons(departmentid: department_id, providerid: provider_id)
        Rails.logger.info(res.to_json)
      end

      it "get a list of open appointments" do
        res = connector.get_open_appointments(departmentid: department_id, 
          appointmenttypeid: 1, startdate: "01/01/1920", enddate: "01/01/2020")
        Rails.logger.info(res.to_json)
        expect(res.empty?).to eq(false)
      end

      it "get a list of booked slots" do
        res = connector.get_booked_appointments(departmentid: department_id, 
          startdate: "01/01/1920", enddate: "01/01/2020")
        Rails.logger.info(res.to_json)
        expect(res.empty?).to eq(false)
        end
    end
  end

  describe "Mock Connector - " do
    it "get a list of appointment types" do
      connector = AthenaHealthApiHelper::MockConnector.new()
      res = connector.get_appointment_types()
      expect(res.empty?).to eq(false)
    end

    it "get a list of appointment reasons" do
      connector = AthenaHealthApiHelper::MockConnector.new()
      res = connector.get_appointment_reasons(departmentid: department_id, providerid: provider_id)
    end

    it "get a list of open appointments" do
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
          } 
        ]
      )
      res = connector.get_open_appointments(departmentid: department_id, 
        appointmenttypeid: 1, startdate: "01/01/1920", enddate: "01/01/2020")
      expect(res.empty?).to eq(false)
    end

    it "get a list of booked slots" do
      connector = AthenaHealthApiHelper::MockConnector.new(
        appointments: [ 
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
      res = connector.get_booked_appointments(departmentid: department_id, 
        startdate: "01/01/1920", enddate: "01/01/2020")
      expect(res.empty?).to eq(false)
    end
  end
end
