require 'rails_helper'
require 'sync_service_helper'

RSpec.describe SyncServiceHelper, type: :helper do
  describe "Sync Service Helper - " do
    let!(:future_appointment_status){ create(:appointment_status, :future) }
    let!(:cancelled_appointment_status){ create(:appointment_status, :cancelled) }
    let!(:connector) { double("connector") }
    let!(:unknown_user) { create(:user, :guardian, email: 'sync@leohealth.com') }
    let!(:unknown_patient) { create(:patient, family: unknown_user.family)}
    let!(:syncer) { SyncServiceHelper::Syncer.new(connector) }
    let!(:practice) { build(:practice, athena_id: 1) }

    describe "process_scan_appointments" do
      it "creates sync task for unsynced appointment" do
        appt = create(:appointment, athena_id: 0, start_datetime: DateTime.now + 1.minutes)
        expect(SyncTask).to receive(:find_or_create_by).with(sync_id: appt.id, sync_type: :appointment.to_s)
        syncer.process_scan_appointments(SyncTask.new())
      end

      it "creates sync task for stale appointment" do
        appt = create(:appointment, athena_id: 1, sync_updated_at: 1.year.ago, start_datetime: DateTime.now + 1.minutes)
        expect(SyncTask).to receive(:find_or_create_by).with(sync_id: appt.id, sync_type: :appointment.to_s)
        syncer.process_scan_appointments(SyncTask.new())
      end
    end

    describe "process_scan_providers" do
      let!(:provider_sync_profile) { create(:provider_sync_profile) }

      it "creates provider_leave sync task for new provider" do
        expect(SyncTask).to receive(:find_or_create_by).with(sync_id: provider_sync_profile.provider_id, sync_type: :provider_leave.to_s)
        syncer.process_scan_providers(SyncTask.new())
      end

      it "creates provider_leave sync task for stale provider" do
        provider_sync_profile.leave_updated_at = 1.year.ago
        provider_sync_profile.save!

        expect(SyncTask).to receive(:find_or_create_by).with(sync_id: provider_sync_profile.provider_id, sync_type: :provider_leave.to_s)
        syncer.process_scan_providers(SyncTask.new())
      end
    end

    describe "process_scan_remote_appointments" do
      let!(:provider) { create(:user, :clinical) }
      let!(:booked_appt) {
        Struct.new(:appointmentstatus, :appointmenttype, :providerid, :duration, :date, :starttime, :patientappointmenttypename, :appointmenttypeid, :departmentid, :appointmentid, :patientid)
        .new('f', "appointmenttype", "1", "30", Date.tomorrow.strftime("%m/%d/%Y"), "08:00", "patientappointmenttypename", "1", provider.practice.athena_id, "1", "1")
      }
      let(:family) { create(:family) }
      let!(:provider_sync_profile) { create(:provider_sync_profile, athena_id: 1, provider: provider) }
      let!(:appointment_type) { create(:appointment_type, :well_visit, athena_id: 1) }

      it "creates leo appointment when missing" do
        patient = create(:patient, athena_id: 1, family_id: family.id)

        expect(connector).to receive("get_booked_appointments").and_return([ booked_appt ])
        syncer.process_scan_remote_appointments(SyncTask.new(sync_id: booked_appt.departmentid.to_i))
        appt = Appointment.find_by(athena_id: booked_appt.appointmentid.to_i)
        expect(appt).not_to be_nil
        expect(appt.patient_id).to eq(patient.id)
      end

      it "creates leo appointment with unknown patient when missing" do
        expect(connector).to receive("get_booked_appointments").and_return([ booked_appt ])
        syncer.process_scan_remote_appointments(SyncTask.new(sync_id: booked_appt.departmentid.to_i))
        appt = Appointment.find_by(athena_id: booked_appt.appointmentid.to_i)
        expect(appt).not_to be_nil
        expect(appt.patient_id).to eq(unknown_patient.id)
      end
    end

    describe "process_appointment" do
      let!(:family) { create(:family) }
      let!(:patient) { create(:patient, athena_id: 1, family_id: family.id) }
      let(:provider) { create(:user, :clinical) }
      let!(:provider_sync_profile) { create(:provider_sync_profile, athena_id: 1, athena_department_id: 1, provider: provider) }
      let!(:appointment_type) { create(:appointment_type, :well_visit, athena_id: 1) }

      it "creates athena appointment when missing" do
        appointment = create(:appointment, provider_id: provider.id, appointment_type_id: appointment_type.id, appointment_status: future_appointment_status, notes: "notes", start_datetime: DateTime.now + 1.minutes)
        appointment.patient.athena_id = 1
        appointment.patient.save!

        expect(connector).to receive("create_appointment").and_return(1000)
        expect(connector).to receive("book_appointment")
        expect(connector).to receive("create_appointment_note")
        expect(connector).to receive("get_appointment").and_return(AthenaHealthApiHelper::AthenaStruct.new({
          "date": Date.tomorrow.strftime("%m/%d/%Y"),
          "appointmentid": "1000",
          "departmentid": "1",
          "appointmenttype": "Lab Work",
          "providerid": provider_sync_profile.athena_id.to_s,
          "starttime": "15:25",
          "appointmentstatus": "f",
          "patientid": appointment.patient.athena_id.to_s,
          "duration": "15",
          "appointmenttypeid": appointment_type.athena_id.to_s,
          "patientappointmenttypename": "Lab Work"
          }))

        syncer.process_appointment(SyncTask.new(sync_id: appointment.id))

        expect(appointment.reload.athena_id).to eq(1000)
      end

      it "cancels athena appointment when cancelled" do
        appointment = create(:appointment, provider_id: provider.id, appointment_type_id: appointment_type.id, athena_id: 1000, appointment_status: cancelled_appointment_status, start_datetime: DateTime.now + 1.minutes)
        appointment.patient.athena_id = 1
        appointment.patient.save!

        expect(connector).to receive("get_appointment").and_return(AthenaHealthApiHelper::AthenaStruct.new({
          "date": Date.tomorrow.strftime("%m/%d/%Y"),
          "appointmentid": "1000",
          "departmentid": "1",
          "appointmenttype": "Lab Work",
          "providerid": provider_sync_profile.athena_id.to_s,
          "starttime": "15:25",
          "appointmentstatus": "f",
          "patientid": appointment.patient.athena_id.to_s,
          "duration": "30",
          "appointmenttypeid": appointment_type.athena_id.to_s,
          "patientappointmenttypename": "Lab Work"
          }))
        expect(connector).to receive("cancel_appointment")

        syncer.process_appointment(SyncTask.new(sync_id: appointment.id))

        appointment.reload
        expect(appointment.athena_id).to eq(1000)
      end

      it "updates leo appointment" do
        appointment = create(:appointment, provider_id: provider.id, appointment_type_id: appointment_type.id, athena_id: 1000, appointment_status: future_appointment_status, start_datetime: DateTime.now + 1.minutes)
        appointment.patient.athena_id = 1
        appointment.patient.save!

        expect(connector).to receive("get_appointment").and_return(AthenaHealthApiHelper::AthenaStruct.new({
          "date": Date.tomorrow.strftime("%m/%d/%Y"),
          "appointmentid": "1000",
          "departmentid": "1",
          "appointmenttype": "Lab Work",
          "providerid": provider_sync_profile.athena_id.to_s,
          "starttime": "15:25",
          "appointmentstatus": "f",
          "patientid": appointment.patient.athena_id.to_s,
          "duration": "60",
          "appointmenttypeid": appointment_type.athena_id.to_s,
          "patientappointmenttypename": "Lab Work"
          }))

        syncer.process_appointment(SyncTask.new(sync_id: appointment.id))

        appointment.reload
        expect(appointment.athena_id).to eq(1000)
        expect(appointment.duration).to eq(60)
      end

      it "updates leo appointment with rescheduled_id" do
        appointment = create(:appointment, provider_id: provider.id, appointment_type_id: appointment_type.id, athena_id: 1000, appointment_status: future_appointment_status, start_datetime: DateTime.now + 1.minutes)
        appointment.patient.athena_id = 1
        appointment.patient.save!

        resched_appointment = create(:appointment, start_datetime: DateTime.now + 10.minutes, provider_id: provider.id, appointment_type_id: appointment_type.id, athena_id: 1001)
        resched_appointment.patient.athena_id = 1
        resched_appointment.patient.save!

        expect(connector).to receive("get_appointment").and_return(AthenaHealthApiHelper::AthenaStruct.new({
          "date": Date.tomorrow.strftime("%m/%d/%Y"),
          "appointmentid": "1000",
          "departmentid": "1",
          "appointmenttype": "Lab Work",
          "providerid": provider_sync_profile.athena_id.to_s,
          "starttime": "15:25",
          "appointmentstatus": "x",
          "rescheduledappointmentid": "1001",
          "patientid": appointment.patient.athena_id.to_s,
          "duration": "60",
          "appointmenttypeid": appointment_type.athena_id.to_s,
          "patientappointmenttypename": "Lab Work"
          }))

        syncer.process_appointment(SyncTask.new(sync_id: appointment.id))

        appointment.reload
        expect(appointment.athena_id).to eq(1000)
        expect(appointment.duration).to eq(60)
        expect(appointment.appointment_status_id).to eq(AppointmentStatus.find_by(status: 'x').id)
        expect(appointment.rescheduled_id).to eq(resched_appointment.id)
      end
    end

    describe "process_scan_patients" do
      let!(:family) { create(:family) }
      let!(:parent) { create(:user, :guardian, family: family) }
      let!(:patient){ create(:patient, athena_id: 0, family: family) }

      context "for unsynced patient" do
        it "should creates sync tasks" do
          expect{ syncer.process_scan_patients(SyncTask.new) }.to change{ SyncTask.count }.from(0).to(7)
        end
      end

      context "for stale patient" do
        before do
          patient.update_attributes(athena_id: 1)
        end

        it "creates sync tasks" do
          expect{ syncer.process_scan_patients(SyncTask.new) }.to change{ SyncTask.count }.from(0).to(7)
        end
      end
    end

    describe "process_patient" do
      let!(:family) { create(:family) }
      let!(:insurance_plan) { create(:insurance_plan, athena_id: 100) }
      let!(:parent) { create(:user, :guardian, family: family, insurance_plan: insurance_plan, practice: practice) }

      it "creates new patient" do
        patient = create(:patient, athena_id: 0, family_id: family.id)

        expect(connector).to receive("create_patient").with(hash_including(dob: patient.birth_date.strftime("%m/%d/%Y"))).and_return(1000)
        expect(connector).to receive("get_best_match_patient").and_return(nil)
        expect(connector).to receive("get_best_match_patient").and_return(nil)
        expect(connector).to receive("get_patient_insurances").and_return(JSON.parse(%q(
                [{
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
                }]
          )))
        syncer.process_patient(SyncTask.new(sync_id: patient.id))
        expect(patient.reload.athena_id).to eq(1000)
      end

      it "uses best match patient" do
        patient = create(:patient, athena_id: 0, family_id: family.id)

        expect(connector).to receive("get_best_match_patient").and_return(AthenaHealthApiHelper::AthenaStruct.new({
              "racename": "White",
              "occupationcode": nil,
              "homephone": "5555173402",
              "guarantorstate": "MA",
              "portalaccessgiven": "true",
              "driverslicense": "false",
              "contactpreference_appointment_email": "true",
              "contactpreference_appointment_sms": "false",
              "contactpreference_billing_phone": "true",
              "ethnicitycode": nil,
              "contactpreference_announcement_phone": "true",
              "industrycode": nil,
              "contacthomephone": "8885551241",
              "guarantorssn": nil,
              "contactpreference_lab_sms": "false",
              "zip": "02539",
              "guarantoraddresssameaspatient": "true",
              "employerphone": nil,
              "contactmobilephone": nil,
              "nextkinphone": nil,
              "portaltermsonfile": "true",
              "status": "active",
              "lastname": "Jones",
              "guarantorfirstname": "Donald",
              "city": "EDGARTOWN",
              "ssn": "*****5954",
              "guarantorcity": "EDGARTOWN",
              "guarantorzip": "02539",
              "sex": "F",
              "privacyinformationverified": "true",
              "primarydepartmentid": "1",
              "contactpreference_lab_email": "true",
              "balances": [{
                  "balance": 0,
                  "departmentlist": "1,21,102,145,148,150,157,162",
                  "providergroupid": "1",
                  "cleanbalance": "true"
              }, {
                  "balance": 0,
                  "departmentlist": "62,142,164",
                  "providergroupid": "2",
                  "cleanbalance": "true"
              }],
              "contactpreference_announcement_sms": "false",
              "race": ["2106-3"],
              "language6392code": "eng",
              "primaryproviderid": "74",
              "patientphoto": "false",
              "contactpreference_billing_email": "true",
              "contactpreference_announcement_email": "true",
              "caresummarydeliverypreference": "PORTAL",
              "guarantorlastname": "Jones",
              "firstname": "Ariana",
              "guarantorcountrycode": "USA",
              "state": "MA",
              "contactpreference_appointment_phone": "true",
              "patientid": "1978",
              "dob": "10\/13\/1951",
              "guarantorrelationshiptopatient": "3",
              "address1": "8762 Stoneridge Ct",
              "contactpreference_billing_sms": "false",
              "guarantorphone": nil,
              "maritalstatus": "S",
              "countrycode": "USA",
              "guarantoraddress1": "8762 Stoneridge Ct",
              "maritalstatusname": "SINGLE",
              "consenttotext": "false",
              "countrycode3166": "US",
              "contactpreference_lab_phone": "true",
              "guarantorcountrycode3166": "US"
          }))
        expect(connector).to receive("get_patient_insurances").and_return(JSON.parse(%q(
                [{
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
                }]
          )))
        syncer.process_patient(SyncTask.new(sync_id: patient.id))
        expect(patient.reload.athena_id).to eq(1978)
      end

      it "updates stale patient" do
        patient = create(:patient, athena_id: 1, family_id: family.id)
        expect(connector).to receive("get_patient_insurances").and_return(JSON.parse(%q(
                [{
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
                }]
          )))

        expect(connector).to receive("update_patient").with(hash_including(dob: patient.birth_date.strftime("%m/%d/%Y")))
        syncer.process_patient(SyncTask.new(sync_id: patient.id))
      end

      it "creates new patient and insurance" do
        patient = create(:patient, athena_id: 0, family_id: family.id)

        expect(connector).to receive("create_patient").with(hash_including(dob: patient.birth_date.strftime("%m/%d/%Y"))).and_return(1000)
        expect(connector).to receive("get_best_match_patient").and_return(nil)
        expect(connector).to receive("get_best_match_patient").and_return(nil)
        expect(connector).to receive("get_patient_insurances").and_return([])
        expect(connector).to receive("create_patient_insurance").with(hash_including(:insurancepackageid => insurance_plan.athena_id))
        syncer.process_patient(SyncTask.new(sync_id: patient.id))
        expect(patient.reload.athena_id).to eq(1000)
      end

      it "updates stale patient and creates insurance" do
        patient = create(:patient, athena_id: 1, family_id: family.id)

        expect(connector).to receive("update_patient").with(hash_including(dob: patient.birth_date.strftime("%m/%d/%Y")))
        expect(connector).to receive("get_patient_insurances").and_return([])
        expect(connector).to receive("create_patient_insurance").with(hash_including(:insurancepackageid => insurance_plan.athena_id))
        syncer.process_patient(SyncTask.new(sync_id: patient.id))
      end
    end

    describe "process_patient_photo" do
      let!(:family) { create(:family) }
      let!(:patient) { create(:patient, athena_id: 1, family_id: family.id) }

      it "deletes photo if none available" do
        expect(connector).to receive("delete_patient_photo")
        syncer.process_patient_photo(SyncTask.new(sync_id: patient.id))
      end

      it "sets photo if one is available" do
        photo = create(:photo, patient_id: patient.id)

        expect(connector).to receive("set_patient_photo")
        syncer.process_patient_photo(SyncTask.new(sync_id: patient.id))
      end
    end

    describe "process_patient_allergies" do
      let!(:practice) { build(:practice, athena_id: 1) }
      let!(:family) { create(:family) }
      let!(:parent) { create(:user, :guardian, family: family, practice: practice) }
      let!(:patient) { create(:patient, athena_id: 1, family_id: family.id) }

      it "creates alergy" do
        expect(connector).to receive("get_patient_allergies").and_return(JSON.parse(%q(
            [{
                "allergenname": "Abbokinase",
                "allergenid": "18581",
                "reactions": [],
                "note": "TestingNote"
            }]
        )))
        syncer.process_patient_allergies(SyncTask.new(sync_id: patient.id))
        expect(Allergy.count).to be(1)
      end

      it "creates alergy with severity" do
        expect(connector).to receive("get_patient_allergies").and_return(JSON.parse(%q(
            [{
                "allergenname": "Abbokinase",
                "allergenid": "18581",
                "reactions": [{
                  "reactionname": "rash",
                  "snomedcode": "271807003",
                  "severity" : "acute"
                }],
                "note": "TestingNote"
            }]
        )))
        syncer.process_patient_allergies(SyncTask.new(sync_id: patient.id))
        expect(Allergy.count).to be(1)
      end

      it "creates alergy with reactions, no severity" do
        expect(connector).to receive("get_patient_allergies").and_return(JSON.parse(%q(
            [{
                "allergenname": "Abbokinase",
                "allergenid": "18581",
                "reactions": [{
                  "reactionname": "rash",
                  "snomedcode": "271807003"
                }],
                "note": "TestingNote"
            }]
        )))
        syncer.process_patient_allergies(SyncTask.new(sync_id: patient.id))
        expect(Allergy.count).to be(1)
      end

    end

    describe "process_patient_medications" do
      let!(:family) { create(:family) }
      let!(:practice) { build(:practice, athena_id: 1) }
      let!(:parent) { create(:user, :guardian, family: family, practice: practice) }
      let!(:patient) { create(:patient, athena_id: 1, family_id: family.id) }

      it "creates medication with unstructured sig" do
        expect(connector).to receive("get_patient_medications").and_return(JSON.parse(%q(
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
                  }]
          )))

        syncer.process_patient_medications(SyncTask.new(sync_id: patient.id))
        expect(Medication.count).to be(1)
      end

      it "creates medication with structured sig" do
        expect(connector).to receive("get_patient_medications").and_return(JSON.parse(%q(
                [{
                    "source": "jdoe",
                    "createdby": "jdoe",
                    "isstructuredsig": "true",
                    "medicationid": "244875",
                    "issafetorenew": "true",
                    "medicationentryid": "H462",
                    "structuredsig": {
                        "dosagefrequencyvalue": "1",
                        "dosageroute": "oral",
                        "dosageaction": "Take",
                        "dosageadditionalinstructions": "before meals",
                        "dosagefrequencyunit": "per day",
                        "dosagequantityunit": "tablet(s)",
                        "dosagequantityvalue": "1",
                        "dosagefrequencydescription": "every day",
                        "dosagedurationunit": "day"
                    },
                    "events": [{
                        "eventdate": "04\/20\/2011",
                        "type": "START"
                    }, {
                        "eventdate": "06\/11\/2013",
                        "type": "HIDE"
                    }, {
                        "eventdate": "05\/10\/2011",
                        "type": "ENTER"
                    }],
                    "medication": "Coumadin 2 mg tablet",
                    "unstructuredsig": "Take 1 tablet(s) every day by oral route before meals."
                }]
          )))

        syncer.process_patient_medications(SyncTask.new(sync_id: patient.id))
        expect(Medication.count).to be(1)
      end
    end

    describe "process_patient_vitals" do
      let!(:family) { create(:family) }
      let!(:practice) { build(:practice, athena_id: 1) }
      let!(:parent) { create(:user, :guardian, family: family, practice: practice) }
      let!(:patient) { create(:patient, athena_id: 1, family_id: family.id) }

      it "creates medication" do
        expect(connector).to receive("get_patient_vitals").and_return(JSON.parse(%q(
                [{
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
                }]
          )))

        syncer.process_patient_vitals(SyncTask.new(sync_id: patient.id))
        expect(Vital.count).to be(3)
      end
    end

    describe "process_patient_vaccines" do
      let!(:family) { create(:family) }
      let!(:practice) { build(:practice, athena_id: 1) }
      let!(:parent) { create(:user, :guardian, family: family, practice: practice) }
      let!(:patient) { create(:patient, athena_id: 1, family_id: family.id) }

      it "creates vaccine" do
        expect(connector).to receive("get_patient_vaccines").and_return(JSON.parse(%q(
              [{
                  "mvx": "UNK",
                  "status": "ADMINISTERED",
                  "administerdate": "11\/10\/1969",
                  "vaccineid": "H121",
                  "description": "diphtheria, tetanus toxoids and pertussis vaccine",
                  "vaccinetype": "HISTORICAL",
                  "cvx": "01"
              }]
          )))

        syncer.process_patient_vaccines(SyncTask.new(sync_id: patient.id))
        expect(Vaccine.count).to be(1)
      end
    end

    describe "process_patient_insurances" do
      let!(:family) { create(:family) }
      let!(:practice) { build(:practice, athena_id: 1) }
      let!(:parent) { create(:user, :guardian, family: family, practice: practice) }
      let!(:patient) { create(:patient, athena_id: 1, family_id: family.id) }

      it "creates insurance" do
        expect(connector).to receive("get_patient_insurances").and_return(JSON.parse(%q(
                [{
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
                }]
          )))

        syncer.process_patient_insurances(SyncTask.new(sync_id: patient.id))
        expect(Insurance.count).to be(1)
      end
    end

    describe "process_provider_leave" do
      it "creates new provider leave entries" do
        provider_sync_profile = create(:provider_sync_profile, athena_id: 1)
        block_appointment_type = create(:appointment_type, :block, athena_id: 1)

        expect(connector).to receive("get_open_appointments").and_return(
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
              }))), 
            AthenaHealthApiHelper::AthenaStruct.new(JSON.parse(%q({
              "date": "12\/26\/2015",
              "appointmentid": "389202",
              "departmentid": "1",
              "appointmenttype": "Block",
              "providerid": "1",
              "starttime": "10:30",
              "duration": "10",
              "appointmenttypeid": "2",
              "reasonid": ["-1"],
              "patientappointmenttypename": "Block"
              })))
          ]
          )
        syncer.process_provider_leave(SyncTask.new(sync_id: provider_sync_profile.provider_id))
        expect(ProviderLeave.where(athena_provider_id: provider_sync_profile.athena_id).where.not(athena_id: 0).count).to be(1)
        expect(ProviderLeave.where(athena_provider_id: provider_sync_profile.athena_id).where.not(athena_id: 0).first.start_datetime).to eq(Time.zone.parse("30/10/2015 12:12").to_datetime)
        expect(ProviderLeave.where(athena_provider_id: provider_sync_profile.athena_id).where.not(athena_id: 0).first.end_datetime).to eq(Time.zone.parse("30/10/2015 12:42").to_datetime)
      end
    end
  end
end
