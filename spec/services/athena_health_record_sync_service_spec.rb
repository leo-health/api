require "rails_helper"
describe AthenaPatientSyncService do
  before do
    @service = AthenaHealthRecordSyncService.new
    @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance
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
