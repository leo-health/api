require 'rails_helper'
require 'athena_health_api_helper'

RSpec.describe AthenaHealthApiHelper, type: :helper do
  describe "Athena Health Api Connector - " do
    let(:connection){double("connection")}
    let!(:connector) {AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)}

    describe "get appointment" do
      it "should return an appointment" do
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

        appointment = connector.get_appointment(appointmentid: 1000)

        expect(appointment).not_to be_nil
        expect(appointment.appointmentid).to eq("1000")
      end
    end

    describe "delete appointment" do
      it "should delete an appointment" do
        allow(connection).to receive("DELETE").and_return(Struct.new(:code, :body).new(200, %q(
          [{
          "appointmentid": "1000"
          }]
          )))

        expect { connector.delete_appointment(appointmentid: 1000) }.not_to raise_error
      end
    end

    describe "create appointment" do
      it "should create an appointment" do
        allow(connection).to receive("POST").and_return(Struct.new(:code, :body).new(200, %q(
          {
          "appointmentids": {
          "393837": "01:00"
          }
          }
          )))

        appointment = connector.create_appointment(appointmentdate: "01/01/2001", appointmenttime: "01:00", appointmenttypeid: 1, departmentid: 1, providerid: 1)
        expect(appointment).to eq(393837)
      end
    end

    describe "book appointment" do
      it "should book an appointment" do
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

        expect { connector.book_appointment(appointmentid: 393837, appointmenttypeid: 2, patientid: 1) }.not_to raise_error
      end
    end

    describe "cancel appointment" do
      it "should cancel an appointment" do
        allow(connection).to receive("PUT").and_return(Struct.new(:code, :body).new(200, %q(
          {
          "status": "x"
          }
          )))

        expect { connector.cancel_appointment(appointmentid: 393837, patientid: 1) }.not_to raise_error
      end
    end

    describe "reschedule appointment" do
      it "should reschedule an appointment" do
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

        expect { connector.reschedule_appointment(appointmentid: 393837, newappointmentid: 393841, patientid: 1) }.not_to raise_error
      end
    end

    describe "freeze appointment" do
      it "should freeze an appointment" do
        allow(connection).to receive("PUT").and_return(Struct.new(:code, :body).new(200, %q(
          {
          "success": "true"
          }
          )))

        expect { connector.freeze_appointment(appointmentid: 393837) }.not_to raise_error
      end
    end

    describe "checkin appointment" do

      it "should checkin an appointment" do
        allow(connection).to receive("POST").and_return(Struct.new(:code, :body).new(200, %q(
          )))
        expect { connector.checkin_appointment(appointmentid: 393837) }.not_to raise_error
      end
    end

    describe "get appointment types" do
      it "should get a list of appointment types" do
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

        appointment_types = connector.get_appointment_types()

        expect(appointment_types).not_to be_nil
        expect(appointment_types.length).to be(2)
        expect(appointment_types[0]["shortname"]).to eq("ALLG")
      end
    end

    describe "get appointment reasons" do
      it "should get the appointment reasons" do
        allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
          {
          "totalcount": 0,
          "patientappointmentreasons": []
          }
          )))

        appointment_types = connector.get_appointment_reasons(departmentid: 1, providerid: 1)

        expect(appointment_types).not_to be_nil
        expect(appointment_types.length).to be(0)
      end
    end

    describe "get open appointments" do
      it "should return a list of appointments" do
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
        
        appointments = connector.get_open_appointments(departmentid: 1, providerid: 1)

        expect(appointments).not_to be_nil
        expect(appointments.length).to be(2)
        expect(appointments[0].appointmentid).to eq("378717")
      end
    end

    describe "get booked appointments" do
      it "should return a list of booked appointments" do
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

        appointments = connector.get_booked_appointments(departmentid: 1, providerid: 1, startdate: "01/01/2001", enddate: "01/01/2001")

        expect(appointments).not_to be_nil
        expect(appointments.length).to be(2)
        expect(appointments[0].appointmentid).to eq("378717")
      end
    end

    describe "create patient" do
      it "should create a patient" do
        allow(connection).to receive("POST").and_return(Struct.new(:code, :body).new(200, %q(
          [{
          "patientid": "5031"
          }]
          )))

        patient = connector.create_patient(firstname: "First", lastname: "Last", dob: "01/01/2001", guarantoremail: "g@g.com", departmentid: 1)
        expect(patient).to eq (5031)
      end
    end

    describe "get patient" do
      it "should return a patient" do
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

        patient = connector.get_patient(patientid: 5031)
        expect(patient).not_to be_nil
        expect(patient.patientid).to eq ("5031")
      end
    end
  end
end
