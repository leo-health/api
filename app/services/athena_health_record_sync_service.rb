class AthenaHealthRecordSyncService < AthenaSyncService

  def sync_health_record(leo_patient)
    if leo_patient.athena_id == 0
      AthenaPatientSyncService.new.sync_patient(leo_patient)
      if leo_patient.athena_id == 0
        @logger.info("Skipping sync for vaccines due to patient #{leo_patient.id} sync failure")
        return
      end
    end

    [:vitals, :medications, :vaccines, :allergies].each do |s|
      send("sync_#{s.to_s}".to_sym, leo_patient)
    end
  end

  private

  def sync_allergies(leo_patient)
    raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian

    leo_parent = leo_patient.family.primary_guardian

    #get list of allergies for this patients
    allergies = @connector.get_patient_allergies(patientid: leo_patient.athena_id, departmentid: leo_parent.practice.athena_id)

    #remove existing allergies for the user
    Allergy.destroy_all(patient_id: leo_patient.id)

    #create and/or update the allergy records in Leo
    allergies.each do | allergy |
      leo_allergy = Allergy.find_or_create_by!(patient_id: leo_patient.id, athena_id: allergy[:allergenid.to_s].to_i)

      leo_allergy.patient_id = leo_patient.id
      leo_allergy.athena_id = allergy[:allergenid.to_s].to_i
      leo_allergy.allergen = allergy[:allergenname.to_s]
      leo_allergy.onset_at = Date.strptime(allergy[:onsetdate.to_s], "%m/%d/%Y") if allergy[:onsetdate.to_s]

      reactions = []
      reactions = allergy[:reactions.to_s] if allergy[:reactions.to_s]
      leo_allergy.severity = reactions[0][:severity.to_s] if (reactions.size > 0 && reactions[0][:severity.to_s])

      leo_allergy.note = allergy[:note.to_s] if allergy[:note.to_s]

      leo_allergy.save!
    end

    leo_patient.allergies_updated_at = DateTime.now.utc
    leo_patient.save!
  end

  def sync_medications(leo_patient)
    raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian

    leo_parent = leo_patient.family.primary_guardian

    #get list of medications for this patients
    meds = @connector.get_patient_medications(patientid: leo_patient.athena_id, departmentid: leo_parent.practice.athena_id)

    #remove existing medications for the user
    Medication.destroy_all(patient_id: leo_patient.id)

    #create and/or update the medication records in Leo
    meds.each do | med |

      unless med[:medicationid.to_s]
        @logger.error("ERROR: medicationid is null! #{med}")
      else
        leo_med = Medication.find_or_create_by!(athena_id: med[:medicationid.to_s])

        leo_med.patient_id = leo_patient.id
        leo_med.athena_id = med[:medicationid.to_s]
        leo_med.medication = med[:medication.to_s]
        leo_med.sig = med[:unstructuredsig.to_s]
        leo_med.sig ||= ''
        leo_med.note = med[:patientnote.to_s]
        leo_med.note ||= ''

        structured_sig = {}
        structured_sig = med[:structuredsig.to_s]

        if structured_sig
          leo_med.dose = "#{structured_sig[:dosagequantityvalue.to_s]} #{structured_sig[:dosagequantityunit.to_s]} #{structured_sig[:dosagefrequencyvalue.to_s]} #{structured_sig[:dosagefrequencyunit.to_s]}"
        end
        leo_med.dose ||= ''
        leo_med.route = structured_sig[:dosageroute.to_s] if (structured_sig && structured_sig[:dosageroute.to_s])
        leo_med.route ||= ''
        leo_med.frequency = structured_sig[:dosagefrequencydescription.to_s] if (structured_sig && structured_sig[:dosagefrequencydescription.to_s])
        leo_med.frequency ||= ''
        leo_med.started_at = nil
        leo_med.ended_at = nil
        leo_med.ordered_at = nil
        leo_med.filled_at = nil
        leo_med.entered_at = nil
        leo_med.hidden_at = nil

        med[:events.to_s].each do | evt |
          leo_med.started_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'START'.to_sym)
          leo_med.ended_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'END'.to_sym)
          leo_med.ordered_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'ORDER'.to_sym)
          leo_med.filled_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'FILL'.to_sym)
          leo_med.entered_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'ENTER'.to_sym)
          leo_med.hidden_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'HIDE'.to_sym)
        end

        leo_med.save!
      end
    end

    leo_patient.medications_updated_at = DateTime.now.utc
    leo_patient.save!
  end

  def sync_vitals(leo_patient)
    raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian

    leo_parent = leo_patient.family.primary_guardian

    #get list of vitals for this patients
    vitals = @connector.get_patient_vitals(patientid: leo_patient.athena_id, departmentid: leo_parent.practice.athena_id)

    #remove existing vitals for the user
    Vital.destroy_all(patient_id: leo_patient.id)

    #create and/or update the vitals records in Leo
    vitals.each do | vital |
      vital[:readings.to_s].each do | reading_arr |
        reading = reading_arr[0]

        leo_vital = Vital.find_or_create_by!(athena_id: reading[:vitalid.to_s].to_i)

        leo_vital.patient_id = leo_patient.id
        leo_vital.athena_id = reading[:vitalid.to_s].to_i
        leo_vital.measurement = reading[:clinicalelementid.to_s]
        leo_vital.value = reading[:value.to_s]
        leo_vital.taken_at = Date.strptime(reading[:readingtaken.to_s], "%m/%d/%Y") if reading[:readingtaken.to_s]

        leo_vital.save!
      end
    end
    leo_patient.vitals_updated_at = DateTime.now.utc
    leo_patient.save!
  end

  def sync_vaccines(leo_patient)
    raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian

    leo_parent = leo_patient.family.primary_guardian

    #get list of vaccines for this patients
    vaccs = @connector.get_patient_vaccines(patientid: leo_patient.athena_id, departmentid: leo_parent.practice.athena_id)

    #remove existing vaccines for the user
    Vaccine.destroy_all(patient_id: leo_patient.id)

    #create and/or update the vaccine records in Leo
    vaccs.each do | vacc |
      if vacc[:status.to_s] == 'ADMINISTERED'
        leo_vacc = Vaccine.find_or_initialize_by(athena_id: vacc[:vaccineid.to_s])
        leo_vacc.patient_id = leo_patient.id
        leo_vacc.athena_id = vacc[:vaccineid.to_s]
        leo_vacc.vaccine = vacc[:description.to_s]
        leo_vacc.administered_at = Date.strptime(vacc[:administerdate.to_s], "%m/%d/%Y") if vacc[:administerdate.to_s]
        leo_vacc.save!
      end
    end

    leo_patient.vaccines_updated_at = DateTime.now.utc
    leo_patient.save!
  end
end
