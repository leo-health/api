class AthenaPatientSyncService < AthenaSyncService
  def sync_patient(_leo_patient)
    leo_patient = match_update_or_create_in_athena(_leo_patient)
    sync_insurance(leo_patient)
    leo_patient.update(patient_updated_at: DateTime.now.utc)
    leo_patient
  end

  def associate_patient_with_athena_id(athena_id, leo_patient)
    patient = leo_patient
    if existing_leo_patient = Patient.find_by_athena_id(athena_id)

      fam = leo_patient.family
      existing_leo_patient.family = fam
      leo_patient.destroy
      # TODO: dependent destroy family if needed

      if fam.patients.count == 0
        fam.destroy
      end

      patient = existing_leo_patient
    end
    patient.update(athena_id: athena_id)
    patient
  end


  private

  def match_update_or_create_in_athena(_leo_patient)
    leo_patient = _leo_patient
    
    athena_patient_needs_update = true
    if leo_patient.athena_id == 0
      # try to best match
      athena_patient = get_best_match_patient(leo_patient)
      unless athena_patient
        # if it fails, create patient
        athena_patient = @connector.create_patient(to_athena_json(leo_patient))
        raise "Failed to create patient #{leo_patient.id} in athena" unless athena_patient && athena_patient["patientid"]
        athena_patient_needs_update = false
      end
      leo_patient = associate_patient_with_athena_id(athena_patient["patientid"].to_i, leo_patient)
    end

    @connector.update_patient(to_athena_json(leo_patient)) if athena_patient_needs_update
    leo_patient
  end

  def get_best_match_patient(leo_patient)
    leo_parent = leo_patient.family.primary_guardian
    patient_birth_date = leo_patient.birth_date.strftime("%m/%d/%Y") if leo_patient.birth_date
    athena_patient = nil
    begin
      #search by email
      athena_patient = @connector.get_best_match_patient(
      firstname: leo_patient.first_name,
      lastname: leo_patient.last_name,
      dob: patient_birth_date,
      guarantoremail: leo_parent.email) unless athena_patient
    rescue => e
      @logger.error("SYNC: Best match by email failed #{e}. Trying by phone number")
      # try again and throw exceptions
      athena_patient = @connector.get_best_match_patient(
      firstname: leo_patient.first_name,
      lastname: leo_patient.last_name,
      dob: patient_birth_date,
      anyphone: leo_parent.phone.gsub(/[^\d,\.]/, '')) if leo_parent.phone
    end
    athena_patient
  end

  def sync_insurance(leo_patient)
    # TODO: remove this if we can
    #create insurance if not entered yet
    insurances = @connector.get_patient_insurances(patientid: leo_patient.athena_id)
    primary_insurance = insurances.find { |ins| ins[:sequencenumber.to_s].to_i == 1 }

    parent = leo_patient.family.primary_guardian
    parent_birth_date = parent.birth_date.strftime("%m/%d/%Y") if parent.birth_date
    insurance_plan = parent.insurance_plan unless primary_insurance

    #only sync if the insurance plan is registered in athena
    if insurance_plan && insurance_plan.athena_id != 0
      @connector.create_patient_insurance(
      patientid: leo_patient.athena_id,
      insurancepackageid: insurance_plan.athena_id.to_s,
      insurancepolicyholderfirstname: parent.first_name,
      insurancepolicyholderlastname: parent.last_name,
      insurancepolicyholdermiddlename: parent.middle_initial.to_s,
      insurancepolicyholdersex: parent.sex,
      insurancepolicyholderdob: parent_birth_date,
      sequencenumber: 1.to_s
      )
    end
  end

  def to_athena_json(patient)
    parent = patient.family.primary_guardian
    patient_birth_date = patient.birth_date.strftime("%m/%d/%Y") if patient.birth_date
    parent_birth_date = parent.birth_date.strftime("%m/%d/%Y") if parent.birth_date

    guardians = patient.family.guardians.order('created_at ASC')
    contactname = nil
    contactrelationship = nil
    contactmobilephone = nil
    if guardians.size > 1
      contactname = "#{guardians[1].first_name} #{guardians[1].last_name}"
      contactrelationship = "GUARDIAN"
      contactmobilephone = guardians[1].phone
    end
    params = patient.athena_id > 0 ? { patientid: patient.athena_id } : {}
    params.merge({
      departmentid: parent.practice.athena_id,
      firstname: patient.first_name,
      middlename: patient.middle_initial.to_s,
      lastname: patient.last_name,
      sex: patient.sex,
      dob: patient_birth_date,
      mobilephone: parent.phone,
      guarantorfirstname: parent.first_name,
      guarantormiddlename: parent.middle_initial.to_s,
      guarantorlastname: parent.last_name,
      guarantordob: parent_birth_date,
      guarantoremail: parent.email,
      guarantorrelationshiptopatient: 3, #3==child
      guarantorphone: parent.phone,
      contactname: contactname,
      contactrelationship: contactrelationship,
      contactmobilephone: contactmobilephone
    })
  end
end
