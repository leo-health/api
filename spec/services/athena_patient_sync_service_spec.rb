require "rails_helper"
describe AthenaPatientSyncService do
  before do
    @service = AthenaPatientSyncService.new
    @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance
  end

  describe ".post_patient" do
    let!(:practice) { build(:practice, athena_id: 1) }
    let!(:insurance_plan) { create(:insurance_plan, athena_id: 100) }
    let(:parent) { create(:user, :guardian, insurance_plan: insurance_plan, practice: practice) }
    let!(:patient) { create(:patient, athena_id: 0, family: parent.family) }
    let(:insurance_response) { JSON.parse(
      %q([{"insurancepolicyholdercountrycode": "USA",
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
      "insurancepolicyholdercity": "BOSTON" }]))
    }
    context "best match fails" do
      context "insurances exist" do
        it "creates a patient in athena" do
          expect(@connector).to receive(:create_patient).with(hash_including(dob: patient.birth_date.strftime("%m/%d/%Y"))).and_return(1000)
          expect(@connector).to receive(:get_best_match_patient).and_return(nil)
          expect(@connector).to receive(:get_best_match_patient).and_return(nil)
          expect(@connector).to receive(:get_patient_insurances).and_return(insurance_response)
          @service.post_patient patient
          expect(patient.athena_id).to eq(1000)
        end
      end

      context "insurances do not exist" do
        it "creates a patient and insurance in athena" do
          expect(@connector).to receive(:create_patient).with(hash_including(dob: patient.birth_date.strftime("%m/%d/%Y"))).and_return(1000)
          expect(@connector).to receive(:get_best_match_patient).and_return(nil)
          expect(@connector).to receive(:get_best_match_patient).and_return(nil)
          expect(@connector).to receive(:get_patient_insurances).and_return([])
          expect(@connector).to receive(:create_patient_insurance).with(hash_including(insurancepackageid: insurance_plan.athena_id))
          @service.post_patient patient
        end
      end
    end

    context "best match succeeds" do
      it "updates the existing athena patient" do
        expect(@connector).to receive(:get_best_match_patient).and_return(
          AthenaHealthApiHelper::AthenaStruct.new(
            {
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
              "balances": [
                {
                  "balance": 0,
                  "departmentlist": "1,21,102,145,148,150,157,162",
                  "providergroupid": "1",
                  "cleanbalance": "true"
                },
                {
                  "balance": 0,
                  "departmentlist": "62,142,164",
                  "providergroupid": "2",
                  "cleanbalance": "true"
                }
              ],
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
            }
          )
        )
        expect(@connector).to receive(:get_patient_insurances).and_return(insurance_response)
        expect(@connector).to receive(:update_patient).with(hash_including(dob: patient.birth_date.strftime("%m/%d/%Y")))
        @service.post_patient patient
      end
    end
  end
end
    #     describe "process_patient_allergies" do
    #       let(:parent) { create(:user, :guardian) }
    #       let!(:patient) { create(:patient, athena_id: 1, family: parent.family) }
    #
    #       it "creates alergy" do
    #         expect(connector).to receive("get_patient_allergies").and_return(JSON.parse(%q(
    #         [{
    #           "allergenname": "Abbokinase",
    #           "allergenid": "18581",
    #           "reactions": [],
    #           "note": "TestingNote"
    #           }]
    #           )))
    #           syncer.process_patient_allergies(SyncTask.new(sync_id: patient.id))
    #           expect(Allergy.count).to be(1)
    #         end
    #
    #         it "creates alergy with severity" do
    #           expect(connector).to receive("get_patient_allergies").and_return(JSON.parse(%q(
    #           [{
    #             "allergenname": "Abbokinase",
    #             "allergenid": "18581",
    #             "reactions": [{
    #               "reactionname": "rash",
    #               "snomedcode": "271807003",
    #               "severity" : "acute"
    #               }],
    #               "note": "TestingNote"
    #               }]
    #               )))
    #               syncer.process_patient_allergies(SyncTask.new(sync_id: patient.id))
    #               expect(Allergy.count).to be(1)
    #             end
    #
    #             it "creates alergy with reactions, no severity" do
    #               expect(connector).to receive("get_patient_allergies").and_return(JSON.parse(%q(
    #               [{
    #                 "allergenname": "Abbokinase",
    #                 "allergenid": "18581",
    #                 "reactions": [{
    #                   "reactionname": "rash",
    #                   "snomedcode": "271807003"
    #                   }],
    #                   "note": "TestingNote"
    #                   }]
    #                   )))
    #                   syncer.process_patient_allergies(SyncTask.new(sync_id: patient.id))
    #                   expect(Allergy.count).to be(1)
    #                 end
    #
    #               end
    #
    #               describe "process_patient_medications" do
    #                 let!(:practice) { build(:practice, athena_id: 1) }
    #                 let!(:parent) { create(:user, :guardian, practice: practice) }
    #                 let!(:patient) { create(:patient, athena_id: 1, family: parent.family) }
    #
    #                 it "creates medication with unstructured sig" do
    #                   expect(connector).to receive("get_patient_medications").and_return(JSON.parse(%q(
    #                   [{
    #                     "source": "jdoe",
    #                     "createdby": "jdoe",
    #                     "isstructuredsig": "false",
    #                     "medicationid": "243360",
    #                     "issafetorenew": "true",
    #                     "medicationentryid": "H3",
    #                     "events": [{
    #                       "eventdate": "10\/15\/2009",
    #                       "type": "START"
    #                       }, {
    #                         "eventdate": "12\/24\/2009",
    #                         "type": "ENTER"
    #                         }],
    #                         "medication": "benzonatate 100 mg capsule"
    #                         }]
    #                         )))
    #
    #                         syncer.process_patient_medications(SyncTask.new(sync_id: patient.id))
    #                         expect(Medication.count).to be(1)
    #                       end
    #
    #                       it "creates medication with structured sig" do
    #                         expect(connector).to receive("get_patient_medications").and_return(JSON.parse(%q(
    #                         [{
    #                           "source": "jdoe",
    #                           "createdby": "jdoe",
    #                           "isstructuredsig": "true",
    #                           "medicationid": "244875",
    #                           "issafetorenew": "true",
    #                           "medicationentryid": "H462",
    #                           "structuredsig": {
    #                             "dosagefrequencyvalue": "1",
    #                             "dosageroute": "oral",
    #                             "dosageaction": "Take",
    #                             "dosageadditionalinstructions": "before meals",
    #                             "dosagefrequencyunit": "per day",
    #                             "dosagequantityunit": "tablet(s)",
    #                             "dosagequantityvalue": "1",
    #                             "dosagefrequencydescription": "every day",
    #                             "dosagedurationunit": "day"
    #                           },
    #                           "events": [{
    #                             "eventdate": "04\/20\/2011",
    #                             "type": "START"
    #                             }, {
    #                               "eventdate": "06\/11\/2013",
    #                               "type": "HIDE"
    #                               }, {
    #                                 "eventdate": "05\/10\/2011",
    #                                 "type": "ENTER"
    #                                 }],
    #                                 "medication": "Coumadin 2 mg tablet",
    #                                 "unstructuredsig": "Take 1 tablet(s) every day by oral route before meals."
    #                                 }]
    #                                 )))
    #
    #                                 syncer.process_patient_medications(SyncTask.new(sync_id: patient.id))
    #                                 expect(Medication.count).to be(1)
    #                               end
    #                             end
    #
    #                             describe "process_patient_vitals" do
    #                               let!(:family) { create(:family) }
    #                               let!(:practice) { build(:practice, athena_id: 1) }
    #                               let!(:parent) { create(:user, :guardian, family: family, practice: practice) }
    #                               let!(:patient) { create(:patient, athena_id: 1, family_id: family.id) }
    #
    #                               it "creates medication" do
    #                                 expect(connector).to receive("get_patient_vitals").and_return(JSON.parse(%q(
    #                                 [{
    #                                   "ordering": 0,
    #                                   "abbreviation": "BP",
    #                                   "readings": [
    #                                     [{
    #                                       "source": "ENCOUNTER",
    #                                       "value": "100",
    #                                       "readingid": "0",
    #                                       "clinicalelementid": "VITALS.BLOODPRESSURE.SYSTOLIC",
    #                                       "codedescription": "Systolic blood pressure",
    #                                       "sourceid": "22603",
    #                                       "readingtaken": "07\/28\/2015 03:00:56",
    #                                       "codeset": "LOINC",
    #                                       "vitalid": "1069",
    #                                       "code": "8480-6"
    #                                       }, {
    #                                         "source": "ENCOUNTER",
    #                                         "value": "90",
    #                                         "readingid": "0",
    #                                         "clinicalelementid": "VITALS.BLOODPRESSURE.DIASTOLIC",
    #                                         "codedescription": "Diastolic blood pressure",
    #                                         "sourceid": "22603",
    #                                         "readingtaken": "07\/28\/2015 03:00:56",
    #                                         "codeset": "LOINC",
    #                                         "vitalid": "1068",
    #                                         "code": "8462-4"
    #                                         }]
    #                                       ],
    #                                       "key": "BLOODPRESSURE"
    #                                       }, {
    #                                         "ordering": 2,
    #                                         "abbreviation": "Ht",
    #                                         "readings": [
    #                                           [{
    #                                             "source": "ENCOUNTER",
    #                                             "value": "100",
    #                                             "readingid": "0",
    #                                             "clinicalelementid": "VITALS.HEIGHT",
    #                                             "codedescription": "Body height",
    #                                             "sourceid": "22603",
    #                                             "readingtaken": "07\/16\/2015 08:06:26",
    #                                             "codeset": "LOINC",
    #                                             "vitalid": "1029",
    #                                             "code": "8302-2"
    #                                             }]
    #                                           ],
    #                                           "key": "HEIGHT"
    #                                           }, {
    #                                             "ordering": 3,
    #                                             "abbreviation": "Wt",
    #                                             "readings": [
    #                                               [{
    #                                                 "source": "ENCOUNTER",
    #                                                 "value": "70000",
    #                                                 "readingid": "0",
    #                                                 "clinicalelementid": "VITALS.WEIGHT",
    #                                                 "codedescription": "Body weight Measured",
    #                                                 "sourceid": "22603",
    #                                                 "readingtaken": "07\/16\/2015 08:10:32",
    #                                                 "codeset": "LOINC",
    #                                                 "vitalid": "1030",
    #                                                 "code": "3141-9"
    #                                                 }]
    #                                               ],
    #                                               "key": "WEIGHT"
    #                                               }]
    #                                               )))
    #
    #                                               syncer.process_patient_vitals(SyncTask.new(sync_id: patient.id))
    #                                               expect(Vital.count).to be(3)
    #                                             end
    #                                           end
    #
    #                                           describe "process_patient_vaccines" do
    #                                             let!(:family) { create(:family) }
    #                                             let!(:practice) { build(:practice, athena_id: 1) }
    #                                             let!(:parent) { create(:user, :guardian, family: family, practice: practice) }
    #                                             let!(:patient) { create(:patient, athena_id: 1, family_id: family.id) }
    #
    #                                             it "creates vaccine" do
    #                                               expect(connector).to receive("get_patient_vaccines").and_return(JSON.parse(%q(
    #                                               [{
    #                                                 "mvx": "UNK",
    #                                                 "status": "ADMINISTERED",
    #                                                 "administerdate": "11\/10\/1969",
    #                                                 "vaccineid": "H121",
    #                                                 "description": "diphtheria, tetanus toxoids and pertussis vaccine",
    #                                                 "vaccinetype": "HISTORICAL",
    #                                                 "cvx": "01"
    #                                                 }]
    #                                                 )))
    #
    #                                                 syncer.process_patient_vaccines(SyncTask.new(sync_id: patient.id))
    #                                                 expect(Vaccine.count).to be(1)
    #                                               end
    #                                             end
    #
    #                                             describe "process_patient_insurances" do
    #                                               let(:parent) { create(:user, :guardian) }
    #                                               let!(:patient) { create(:patient, athena_id: 1, family: parent.family) }
    #
    #                                               it "creates insurance" do
    #                                                 expect(connector).to receive("get_patient_insurances").and_return(JSON.parse(response_body))
    #
    #                                                 syncer.process_patient_insurances(SyncTask.new(sync_id: patient.id))
    #                                                 expect(Insurance.count).to be(1)
    #                                               end
    #                                             end
