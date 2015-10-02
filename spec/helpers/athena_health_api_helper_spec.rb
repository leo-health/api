require 'rails_helper'
require 'athena_health_api_helper'

RSpec.describe AthenaHealthApiHelper, type: :helper do
  describe "Athena Health Api Connector - " do
    let(:connection){double("connection")}
    let!(:connector) {AthenaHealthApiHelper::AthenaHealthApiConnector.new(connection: connection)}

    describe "get_appointment" do
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

    describe "delete_appointment" do
      it "should delete an appointment" do
        allow(connection).to receive("DELETE").and_return(Struct.new(:code, :body).new(200, %q(
          [{
          "appointmentid": "1000"
          }]
          )))

        expect { connector.delete_appointment(appointmentid: 1000) }.not_to raise_error
      end
    end

    describe "create_appointment" do
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

    describe "book_appointment" do
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

    describe "cancel_appointment" do
      it "should cancel an appointment" do
        allow(connection).to receive("PUT").and_return(Struct.new(:code, :body).new(200, %q(
          {
          "status": "x"
          }
          )))

        expect { connector.cancel_appointment(appointmentid: 393837, patientid: 1) }.not_to raise_error
      end
    end

    describe "reschedule_appointment" do
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

    describe "freeze_appointment" do
      it "should freeze an appointment" do
        allow(connection).to receive("PUT").and_return(Struct.new(:code, :body).new(200, %q(
          {
          "success": "true"
          }
          )))

        expect { connector.freeze_appointment(appointmentid: 393837) }.not_to raise_error
      end
    end

    describe "checkin_appointment" do

      it "should checkin an appointment" do
        allow(connection).to receive("POST").and_return(Struct.new(:code, :body).new(200, %q(
          )))
        expect { connector.checkin_appointment(appointmentid: 393837) }.not_to raise_error
      end
    end

    describe "get_appointment_types" do
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

    describe "get_appointment_reasons" do
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

    describe "get_open_appointments" do
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

    describe "get_booked_appointments" do
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

    describe "create_patient" do
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

    describe "get_patient" do
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

    describe "get_patient_allergies" do
      it "should return allergies" do
        allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
          {
          "nkda": "true",
          "sectionnote": "test",
          "allergies": [{
              "allergenname": "Abbokinase",
              "allergenid": "18581",
              "reactions": [],
              "note": "TestingNote"
          }, {
              "allergenname": "Daily Vite W\/Minerals",
              "allergenid": "55555",
              "reactions": [{
                  "reactionname": "anaphylaxis",
                  "snomedcode": "39579001"
              }]
          }, {
              "allergenname": "wasp venom",
              "allergenid": "18035",
              "reactions": [{
                  "severitysnomedcode": "24484000",
                  "reactionname": "anaphylaxis",
                  "snomedcode": "39579001",
                  "severity": "severe"
              }]
          }, {
              "allergenname": "Z-Tabs",
              "allergenid": "55556",
              "reactions": [{
                  "reactionname": "anaphylaxis",
                  "snomedcode": "39579001"
              }]
          }]
          }
        )))

        allergies = connector.get_patient_allergies(patientid: 5031, departmentid: 1)
        expect(allergies).not_to be_nil
        expect(allergies.length).to eq (4)
      end
    end

    describe "get_patient_medications" do
      it "should return medications" do
        allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
          {
              "medications": [
                  [{
                      "source": "jdoe",
                      "createdby": "jdoe",
                      "isstructuredsig": "false",
                      "medicationid": "243360",
                      "issafetorenew": "true",
                      "medicationentryid": "H3",
                      "events": [{
                          "eventdate": "10\/15\/2009",
                          "type": "START"
                      }, {
                          "eventdate": "12\/24\/2009",
                          "type": "ENTER"
                      }],
                      "medication": "benzonatate 100 mg capsule"
                  }],
                  [{
                      "source": "jdoe",
                      "createdby": "jdoe",
                      "isstructuredsig": "false",
                      "medicationid": "292686",
                      "issafetorenew": "true",
                      "medicationentryid": "H2",
                      "events": [{
                          "eventdate": "10\/15\/2009",
                          "type": "START"
                      }, {
                          "eventdate": "12\/24\/2009",
                          "type": "ENTER"
                      }],
                      "medication": "Flovent HFA 110 mcg\/actuation aerosol inhaler"
                  }]
              ],
              "nomedicationsreported": "false"
          }
        )))

        medications = connector.get_patient_medications(patientid: 5031, departmentid: 1)
        expect(medications).not_to be_nil
        expect(medications.length).to eq (2)
      end
    end

    describe "get_patient_vitals" do
      it "should return vitals" do
        allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
            {
                "vitals": [{
                    "ordering": 0,
                    "abbreviation": "BP",
                    "readings": [
                        [{
                            "source": "ENCOUNTER",
                            "value": "100",
                            "readingid": "0",
                            "clinicalelementid": "VITALS.BLOODPRESSURE.SYSTOLIC",
                            "codedescription": "Systolic blood pressure",
                            "sourceid": "22603",
                            "readingtaken": "07\/28\/2015 03:00:56",
                            "codeset": "LOINC",
                            "vitalid": "1069",
                            "code": "8480-6"
                        }, {
                            "source": "ENCOUNTER",
                            "value": "90",
                            "readingid": "0",
                            "clinicalelementid": "VITALS.BLOODPRESSURE.DIASTOLIC",
                            "codedescription": "Diastolic blood pressure",
                            "sourceid": "22603",
                            "readingtaken": "07\/28\/2015 03:00:56",
                            "codeset": "LOINC",
                            "vitalid": "1068",
                            "code": "8462-4"
                        }]
                    ],
                    "key": "BLOODPRESSURE"
                }, {
                    "ordering": 2,
                    "abbreviation": "Ht",
                    "readings": [
                        [{
                            "source": "ENCOUNTER",
                            "value": "100",
                            "readingid": "0",
                            "clinicalelementid": "VITALS.HEIGHT",
                            "codedescription": "Body height",
                            "sourceid": "22603",
                            "readingtaken": "07\/16\/2015 08:06:26",
                            "codeset": "LOINC",
                            "vitalid": "1029",
                            "code": "8302-2"
                        }]
                    ],
                    "key": "HEIGHT"
                }, {
                    "ordering": 3,
                    "abbreviation": "Wt",
                    "readings": [
                        [{
                            "source": "ENCOUNTER",
                            "value": "70000",
                            "readingid": "0",
                            "clinicalelementid": "VITALS.WEIGHT",
                            "codedescription": "Body weight Measured",
                            "sourceid": "22603",
                            "readingtaken": "07\/16\/2015 08:10:32",
                            "codeset": "LOINC",
                            "vitalid": "1030",
                            "code": "3141-9"
                        }]
                    ],
                    "key": "WEIGHT"
                }],
                "totalcount": 3
            }
        )))

        vitals = connector.get_patient_vitals(patientid: 5031, departmentid: 1)
        expect(vitals).not_to be_nil
        expect(vitals.length).to eq (3)
      end
    end

    describe "get_patient_vacinnes" do
      it "should return vaccines" do
        allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
          {
              "totalcount": 1,
              "vaccines": [{
                  "mvx": "UNK",
                  "status": "ADMINISTERED",
                  "administerdate": "11\/10\/1969",
                  "vaccineid": "H121",
                  "description": "diphtheria, tetanus toxoids and pertussis vaccine",
                  "vaccinetype": "HISTORICAL",
                  "cvx": "01"
              }]
          }
        )))

        vaccines = connector.get_patient_vaccines(patientid: 5031, departmentid: 1)
        expect(vaccines).not_to be_nil
        expect(vaccines.length).to eq (1)
      end
    end

    describe "get_patient_insurances" do
      it "should return insurances" do
        allow(connection).to receive("GET").and_return(Struct.new(:code, :body).new(200, %q(
            {
                "insurances": [{
                    "insurancepolicyholdercountrycode": "USA",
                    "sequencenumber": "1",
                    "insurancepolicyholderssn": "*****2847",
                    "insuranceplanname": "BCBS-MA: SAVER DEDUCTIBLE (PPO)",
                    "insurancetype": "Group Policy",
                    "insurancepolicyholderlastname": "MORENA",
                    "insurancephone": "(800) 443-6657",
                    "insuranceidnumber": "123456789",
                    "insurancepolicyholderstate": "MA",
                    "insurancepolicyholderzip": "02465",
                    "relationshiptoinsuredid": "1",
                    "insuranceid": "802",
                    "insurancepolicyholder": "TAYLOR MORENA",
                    "insurancepolicyholderdob": "01\/17\/1969",
                    "eligibilitylastchecked": "04\/18\/2012",
                    "relationshiptoinsured": "Self",
                    "eligibilitystatus": "Eligible",
                    "insurancepolicyholderfirstname": "TAYLOR",
                    "insurancepolicyholderaddress1": "8762 STONERIDGE CT",
                    "insurancepackageid": "90283",
                    "insurancepolicyholdersex": "M",
                    "eligibilityreason": "Athena",
                    "insurancepolicyholdercountryiso3166": "US",
                    "eligibilitymessage": "Electronic eligibility checking is not available for the provider due to an enrollment or credentialing issue. Please call the payer to verify eligibility.",
                    "ircname": "BCBS-MA",
                    "insurancepolicyholdercity": "BOSTON"
                }],
                "totalcount": 1
            }
        )))

        insurances = connector.get_patient_insurances(patientid: 5031)
        expect(insurances).not_to be_nil
        expect(insurances.length).to eq (1)
      end
    end
  end
end
