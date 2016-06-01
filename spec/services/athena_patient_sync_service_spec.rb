require "rails_helper"
describe AthenaPatientSyncService do
  before do
    @service = AthenaPatientSyncService.new
    @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance
  end

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

  describe ".post_patient" do
    let!(:practice) { build(:practice, athena_id: 1) }
    let!(:insurance_plan) { create(:insurance_plan, athena_id: 100) }
    let(:parent) { create(:user, :guardian, insurance_plan: insurance_plan, practice: practice) }
    let!(:patient) { create(:patient, athena_id: 0, family: parent.family) }
    context "best match fails" do
      context "insurances exist" do
        it "creates a patient in athena" do
          expect(@connector).to receive(:create_patient).with(hash_including(dob: patient.birth_date.strftime("%m/%d/%Y"))).and_return(1000)
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

  describe ".sync_all_patients" do
    let!(:practice){ create(:practice, athena_id: 1) }

    def do_request
      @service.sync_all_patients practice
    end

    before do
      create(:role, :guardian)
      create(:onboarding_group, group_name: :generated_from_athena)
    end

    let!(:athena_patient_1) {{
      "racename" => "Patient Declined",
      "occupationcode" => nil,
      "departmentid" => "1",
      "homephone" => "1234567890",
      "guarantorstate" => "MA",
      "driverslicense" => "false",
      "homebound" => "false",
      "ethnicitycode" => "declined",
      "contactpreference" => "HOMEPHONE",
      "industrycode" => nil,
      "contacthomephone" => nil,
      "guarantorssn" => nil,
      "guarantordob" => "12/12/2015",
      "zip" => "02474",
      "guarantoraddresssameaspatient" => "true",
      "employerphone" => nil,
      "contactmobilephone" => nil,
      "nextkinphone" => nil,
      "portaltermsonfile" => "false",
      "status" => "active",
      "lastname" => "Test",
      "guarantorfirstname" => "Zachary",
      "city" => "ARLINGTON",
      "ssn" => nil,
      "lastappointment" => "02/29/2016 12:30",
      "guarantoremail" => "z@a.com",
      "guarantorcity" => "ARLINGTON",
      "guarantorzip" => "02474",
      "sex" => "F",
      "privacyinformationverified" => "true",
      "primarydepartmentid" => "1",
      "balances" => [{
        "balance" => 0,
        "departmentlist" => "1",
        "cleanbalance" => "true"
      }],
      "emailexists" => "true",
      "race" => [
        "declined"
      ],
      "firstappointment" => "02/16/2016 14:00",
      "language6392code" => "declined",
      "primaryproviderid" => "1",
      "patientphoto" => "false",
      "consenttocall" => "true",
      "hasmobile" => "true",
      "caresummarydeliverypreference" => "PORTAL",
      "guarantorlastname" => "Scott",
      "firstname" => "Praneetha",
      "guarantorcountrycode" => "USA",
      "state" => "MA",
      "patientid" => "2",
      "dob" => "12/12/2015",
      "guarantorrelationshiptopatient" => "3",
      "address1" => "300 Arsenal St",
      "guarantorphone" => "1234567890",
      "maritalstatus" => "U",
      "countrycode" => "USA",
      "guarantoraddress1" => "300 Arsenal St",
      "maritalstatusname" => "UNKNOWN",
      "consenttotext" => "false",
      "countrycode3166" => "US",
      "guarantorcountrycode3166" => "US"
      }}
    context "patient does not exist" do
      it "creates a patient enrollment" do
        expect(@connector).to receive(:get_patients).with(hash_including(departmentid: 1)).and_return([athena_patient_1])
        do_request
        expect(Patient.count).to be(1)
        expect(User.count).to be(1)
      end
    end

    context "patient already exists" do
      before do
        user = create(:user, :guardian)
        create(:patient, family: user.family, athena_id: 2)
      end
      it "does not create a patient enrollment" do
        expect(@connector).to receive(:get_patients).with(hash_including(departmentid: 1)).and_return([athena_patient_1])
        do_request
        expect(Patient.count).to be(1)
        expect(User.count).to be(1)
      end
    end

    context "patient enrollment already exists" do
      before do
        user = create(:user, :guardian)
        create(:patient, family: user.family, athena_id: 2)
      end
      it "creates a patient enrollment" do
        expect(@connector).to receive(:get_patients).with(hash_including(departmentid: 1)).and_return([athena_patient_1])
        do_request
        expect(Patient.count).to be(1)
        expect(User.count).to be(1)
      end
    end

    context "enrollment already exists" do
      before do
        create(:user, email: "z@a.com")
      end
      it "creates a patient and uses the matching enrollment" do
        expect(User.count).to be(1)
        expect(@connector).to receive(:get_patients).with(hash_including(departmentid: 1)).and_return([athena_patient_1])
        do_request
        expect(Patient.count).to be(1)
        expect(User.count).to be(1)
      end
    end
  end

  describe ".sync_allergies" do
    let(:parent) { create(:user, :guardian) }
    let!(:patient) { create(:patient, athena_id: 1, family: parent.family) }

    it "creates alergy" do
      expect(@connector).to receive(:get_patient_allergies).and_return([
        {
          "allergenname" => "Abbokinase",
          "allergenid" => "18581",
          "reactions" => [],
          "note" => "TestingNote"
        }
      ])
      @service.sync_allergies(patient)
      expect(Allergy.where(patient: patient).count).to be(1)
    end
  end


  describe ".sync_medications" do
    let!(:practice) { build(:practice, athena_id: 1) }
    let!(:parent) { create(:user, :guardian, practice: practice) }
    let!(:patient) { create(:patient, athena_id: 1, family: parent.family) }

    it "creates medication with unstructured sig" do
      expect(@connector).to receive(:get_patient_medications).and_return(JSON.parse(
        %q([{
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
      @service.sync_medications patient
      expect(Medication.where(patient: patient).count).to be(1)
    end

    it "creates medication with structured sig" do
      expect(@connector).to receive("get_patient_medications").and_return(JSON.parse(
        %q([{
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
          "events": [
            {
            "eventdate": "04\/20\/2011",
            "type": "START"
            },
            {
              "eventdate": "06\/11\/2013",
              "type": "HIDE"
            },
            {
              "eventdate": "05\/10\/2011",
              "type": "ENTER"
            }
          ],
          "medication": "Coumadin 2 mg tablet",
          "unstructuredsig": "Take 1 tablet(s) every day by oral route before meals."
        }]
      )))
      @service.sync_medications patient
      expect(Medication.where(patient: patient).count).to be(1)
    end
  end

  describe ".sync_vaccines" do
    let!(:family) { create(:family) }
    let!(:practice) { build(:practice, athena_id: 1) }
    let!(:parent) { create(:user, :guardian, family: family, practice: practice) }
    let!(:patient) { create(:patient, athena_id: 1, family_id: family.id) }

    it "creates vaccine" do
      expect(@connector).to receive(:get_patient_vaccines).and_return(JSON.parse(
        %q([{
          "mvx": "UNK",
          "status": "ADMINISTERED",
          "administerdate": "11\/10\/1969",
          "vaccineid": "H121",
          "description": "diphtheria, tetanus toxoids and pertussis vaccine",
          "vaccinetype": "HISTORICAL",
          "cvx": "01"
        }]
      )))
      @service.sync_vaccines patient
      expect(Vaccine.where(patient: patient).count).to be(1)
    end
  end
end
