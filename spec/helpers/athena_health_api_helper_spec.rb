require 'rails_helper'
require 'athena_health_api_helper'

RSpec.describe AthenaHealthApiHelper, type: :helper do
  describe "Athena Health Api Connector - " do
    it "get an appointment" do
      connection = double("connection")

      allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
          [{
              "date": "04\/18\/2009",
              "appointmentid": "1000",
              "departmentid": "1",
              "appointmenttype": "Lab Work",
              "providerid": "21",
              "starttime": "15:25",
              "appointmentstatus": "o",
              "duration": "15",
              "appointmenttypeid": "5",
              "patientappointmenttypename": "Lab Work"
          }]
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      appointment = connector.get_appointment(appointmentid: 1000)

      expect(appointment).not_to be_nil
      expect(appointment.appointmentid).to eq("1000")
    end

    it "delete an appointment" do
      connection = double("connection")

      allow(connection).to receive("DELETE").and_return(Struct.new(:code, :body).new(200, %q(
        [{
            "appointmentid": "1000"
        }]
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      expect { connector.delete_appointment(appointmentid: 1000) }.not_to raise_error
    end

    it "create an appointment" do
      connection = double("connection")

      allow(connection).to receive("POST").and_return(Struct.new(:code, :body).new(200, %q(
          {
              "appointmentids": {
                  "393837": "01:00"
              }
          }
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      appointment = connector.create_appointment(appointmentdate: "01/01/2001", appointmenttime: "01:00", appointmenttypeid: 1, departmentid: 1, providerid: 1)
      expect(appointment).to eq(393837)
    end

    it "book an appointment" do
      connection = double("connection")

      allow(connection).to receive("PUT").and_return(Struct.new(:code, :body).new(200, %q(
          [{
              "date": "01\/01\/2010",
              "appointmentid": "393837",
              "departmentid": "1",
              "appointmenttype": "Office Visit",
              "providerid": "",
              "appointmentstatus": "f",
              "duration": "40",
              "appointmenttypeid": "2"
          }]
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      expect { connector.book_appointment(appointmentid: 393837, appointmenttypeid: 2, patientid: 1) }.not_to raise_error
    end

    it "cancel an appointment" do
      connection = double("connection")

      allow(connection).to receive("PUT").and_return(Struct.new(:code, :body).new(200, %q(
          {
              "status": "x"
          }
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      expect { connector.cancel_appointment(appointmentid: 393837, patientid: 1) }.not_to raise_error
    end

    it "reschedule an appointment" do
      connection = double("connection")

      allow(connection).to receive("PUT").and_return(Struct.new(:code, :body).new(200, %q(
          [{
              "appointmentid": "393841",
              "departmentid": "1",
              "providerid": "",
              "appointmentstatus": "f",
              "duration": "40",
              "patientid": "1000",
              "appointmenttypeid": "2"
          }]
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      expect { connector.reschedule_appointment(appointmentid: 393837, newappointmentid: 393841, patientid: 1) }.not_to raise_error
    end

    it "freeze an appointment" do
      connection = double("connection")

      allow(connection).to receive("PUT").and_return(Struct.new(:code, :body).new(200, %q(
          {
          "success": "true"
          }
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      expect { connector.freeze_appointment(appointmentid: 393837) }.not_to raise_error
    end

    it "checkin an appointment" do
      connection = double("connection")

      allow(connection).to receive("POST").and_return(Struct.new(:code, :body).new(200, %q(
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      expect { connector.checkin_appointment(appointmentid: 393837) }.not_to raise_error
    end

    it "get a list of appointment types" do
      connection = double("connection")

      allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
        {
          "totalcount": 2,
          "appointmenttypes": [{
              "shortname": "ALLG",
              "name": "Allergy Test",
              "duration": "30",
              "patientdisplayname": "Allergy Test",
              "appointmenttypeid": "21",
              "generic": "false",
              "patient": "true",
              "templatetypeonly": "false"
          }, {
              "shortname": "ANY5",
              "name": "Any 15",
              "duration": "15",
              "patientdisplayname": "Any 15",
              "appointmenttypeid": "82",
              "generic": "true",
              "patient": "true",
              "templatetypeonly": "false"
          }]
        }
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      appointment_types = connector.get_appointment_types()

      expect(appointment_types).not_to be_nil
      expect(appointment_types.length).to be(2)
      expect(appointment_types[0]["shortname"]).to eq("ALLG")
    end

    it "get a list of appointment reasons" do
      connection = double("connection")

      allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
          {
              "totalcount": 0,
              "patientappointmentreasons": []
          }
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      appointment_types = connector.get_appointment_reasons(departmentid: 1, providerid: 1)

      expect(appointment_types).not_to be_nil
      expect(appointment_types.length).to be(0)
    end

    it "get a list of open appointments" do
      connection = double("connection")

      allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
          {
            "totalcount": 2,
            "appointments": [{
                "date": "10\/10\/2015",
                "appointmentid": "378717",
                "departmentid": "1",
                "appointmenttype": "Follow Up",
                "providerid": "1",
                "starttime": "12:12",
                "duration": "30",
                "appointmenttypeid": "1",
                "reasonid": ["-1"],
                "patientappointmenttypename": "Follow Up Appointment"
            }, {
                "date": "12\/06\/2015",
                "appointmentid": "389202",
                "departmentid": "1",
                "appointmenttype": "Office Visit",
                "providerid": "1",
                "starttime": "10:30",
                "duration": "40",
                "appointmenttypeid": "2",
                "reasonid": ["-1"],
                "patientappointmenttypename": "Office Visit"
            }]
          }
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      appointments = connector.get_open_appointments(departmentid: 1, providerid: 1)

      expect(appointments).not_to be_nil
      expect(appointments.length).to be(2)
      expect(appointments[0].appointmentid).to eq("378717")
    end

    it "get a list of booked appointments" do
      connection = double("connection")

      allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
          {
            "totalcount": 2,
            "appointments": [{
                "date": "10\/10\/2015",
                "appointmentid": "378717",
                "departmentid": "1",
                "appointmenttype": "Follow Up",
                "providerid": "1",
                "starttime": "12:12",
                "duration": "30",
                "appointmenttypeid": "1",
                "reasonid": ["-1"],
                "patientappointmenttypename": "Follow Up Appointment"
            }, {
                "date": "12\/06\/2015",
                "appointmentid": "389202",
                "departmentid": "1",
                "appointmenttype": "Office Visit",
                "providerid": "1",
                "starttime": "10:30",
                "duration": "40",
                "appointmenttypeid": "2",
                "reasonid": ["-1"],
                "patientappointmenttypename": "Office Visit"
            }]
          }
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      appointments = connector.get_booked_appointments(departmentid: 1, providerid: 1, startdate: "01/01/2001", enddate: "01/01/2001")

      expect(appointments).not_to be_nil
      expect(appointments.length).to be(2)
      expect(appointments[0].appointmentid).to eq("378717")
    end

    it "create patient" do
      connection = double("connection")

      allow(connection).to receive("POST").and_return(Struct.new(:code, :body).new(200, %q(
          [{
              "patientid": "5031"
          }]
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      patient = connector.create_patient(firstname: "First", lastname: "Last", dob: "01/01/2001", guarantoremail: "g@g.com", departmentid: 1)
      expect(patient).to eq (5031)
    end

    it "get patient" do
      connection = double("connection")

      allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
          [{
              "occupationcode": null,
              "departmentid": "1",
              "portalaccessgiven": "false",
              "driverslicense": "false",
              "ethnicitycode": null,
              "industrycode": null,
              "contacthomephone": null,
              "guarantorssn": null,
              "guarantoraddresssameaspatient": "true",
              "employerphone": null,
              "contactmobilephone": null,
              "nextkinphone": null,
              "portaltermsonfile": "false",
              "status": "active",
              "lastname": "Last",
              "ssn": null,
              "guarantoremail": "g@g.com",
              "privacyinformationverified": "false",
              "primarydepartmentid": "1",
              "balances": [{
                  "balance": 0,
                  "departmentlist": "1,21,102,145,148,150",
                  "providergroupid": "1",
                  "cleanbalance": "true"
              }],
              "race": [],
              "language6392code": null,
              "primaryproviderid": "",
              "patientphoto": "false",
              "caresummarydeliverypreference": null,
              "firstname": "First",
              "guarantorcountrycode": "USA",
              "patientid": "5031",
              "dob": "01\/01\/2001",
              "guarantorrelationshiptopatient": "1",
              "guarantorphone": null,
              "countrycode": "USA",
              "countrycode3166": "US",
              "guarantorcountrycode3166": "US"
          }]
        )))

      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)
      patient = connector.get_patient(patientid: 5031)
      expect(patient).not_to be_nil
      expect(patient.patientid).to eq ("5031")
    end

    rest = %q(
    it "get a list of appointment reasons" do
      res = connector.get_appointment_reasons(departmentid: department_id, providerid: provider_id)
      Rails.logger.info(res.to_json)
    end

    it "get a list of open appointments" do
      res = connector.get_open_appointments(departmentid: department_id, 
        appointmenttypeid: 1, startdate: "01/01/1920", enddate: "01/01/2020")
      Rails.logger.info(res.to_json)
    end

    it "get a list of booked slots" do
      res = connector.get_booked_appointments(departmentid: department_id, 
        startdate: "01/01/1920", enddate: "01/01/2020")
      Rails.logger.info(res.to_json)
    end

    #don't run modifying tests on athena server
    if !run_athena
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
    )
  end
end
