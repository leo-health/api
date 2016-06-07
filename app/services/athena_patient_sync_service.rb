class AthenaPatientSyncService < AthenaSyncService
  def sync_all_patients(practice)
    athena_patients = @connector.get_patients(departmentid: practice.athena_id).sort_by { |athena_patient| get_athena_id(athena_patient) }
    athena_ids = athena_patients.map { |athena_patient| get_athena_id(athena_patient) }
    existing_athena_ids = Patient.where(athena_id: athena_ids).order(:athena_id).pluck(:athena_id).to_enum
    next_existing_athena_id = nil
    athena_patients.reduce([]) { |created_patients, athena_patient|
      begin
        next_existing_athena_id ||= existing_athena_ids.next
      rescue StopIteration
      end

      if get_athena_id(athena_patient) == next_existing_athena_id
        next_existing_athena_id = nil
      elsif created_patient = create_patient(athena_patient)
        created_patients << created_patient
      end

      created_patients
    }
  end

  def get_athena_id(athena_patient)
    athena_patient["patientid"].try(:to_i)
  end

  def create_patient(athena_patient)
    # TODO: handle guardians with no email
    user_params = parse_athena_patient_json_to_guardian(athena_patient)
    guardian = User.create_with(user_params).find_or_create_by(email: user_params[:email])
    Patient.create({family: guardian.family}.merge(parse_athena_patient_json_to_patient(athena_patient))) if guardian.id
  end

  def parse_athena_patient_json_to_guardian(athena_patient)
    {
      first_name: athena_patient["guarantorfirstname"],
      last_name: athena_patient["guarantorlastname"],
      email: athena_patient["guarantoremail"],
      phone: athena_patient["contactmobilephone"] ||
              athena_patient["homephone"] ||
              athena_patient["employerphone"] ||
              athena_patient["nextkinphone"],
      role: Role.guardian,
      vendor_id: GenericHelper.generate_vendor_id
    }
  end

  def parse_athena_patient_json_to_patient(athena_patient)
    {
      first_name: athena_patient["firstname"],
      last_name: athena_patient["lastname"],
      birth_date: Date.strptime(athena_patient["dob"], "%m/%d/%Y"),
      sex: athena_patient["sex"],
      athena_id: get_athena_id(athena_patient)
    }
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

  def sync_allergies(leo_patient)
    if leo_patient.athena_id == 0
      post_patient(leo_patient)

      if leo_patient.athena_id == 0
        @logger.info("Skipping sync for allergies due to patient #{leo_patient.id} sync failure")
        return
      end
    end

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
    if leo_patient.athena_id == 0
      post_patient(leo_patient)
      if leo_patient.athena_id == 0
        @logger.info("Skipping sync for medications due to patient #{leo_patient.id} sync failure")
        return
      end
    end
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
    if leo_patient.athena_id == 0
      post_patient(leo_patient)
      if leo_patient.athena_id == 0
        @logger.info("Skipping sync for vitals due to patient #{leo_patient.id} sync failure")
        return
      end
    end

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
    if leo_patient.athena_id == 0
      post_patient(leo_patient)
      if leo_patient.athena_id == 0
        @logger.info("Skipping sync for vaccines due to patient #{leo_patient.id} sync failure")
        return
      end
    end

    raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian

    leo_parent = leo_patient.family.primary_guardian

    #get list of vaccines for this patients
    vaccs = @connector.get_patient_vaccines(patientid: leo_patient.athena_id, departmentid: leo_parent.practice.athena_id)

    #remove existing vaccines for the user
    Vaccine.destroy_all(patient_id: leo_patient.id)

    #create and/or update the vaccine records in Leo
    vaccs.each do | vacc |
      if vacc[:status.to_s] == 'ADMINISTERED'
        leo_vacc = Vaccine.find_or_create_by!(athena_id: vacc[:vaccineid.to_s])

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

  def put_patient(patient)
    @connector.update_patient(to_athena_json patient)
  end

  def post_patient(leo_patient)

    @logger.info("Syncer: synching patient=#{leo_patient.to_json}")

    raise "patient.id #{leo_patient.id} has no associated family" unless leo_patient.family
    raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian
    raise "patient.id #{leo_patient.id} has a primary guardian that is not associated with a practice" unless leo_patient.family.primary_guardian.practice

    athena_patient_exists = leo_patient.athena_id > 0
    should_update_athena_patient = true

    unless athena_patient_exists
      athena_patient_exists = best_matched_patient = get_best_match_patient(leo_patient)

      if athena_patient_exists
        raise "patient.id #{leo_patient.id} has a best match in Athena (athena_id: #{best_matched_patient.patientid}), but that match is already connected to another patient" unless Patient.where(athena_id: best_matched_patient.patientid.to_i).empty?
        @logger.info("Syncer: connecting patient.id=#{leo_patient.id} to athena patient.id=#{best_matched_patient.patientid}")
        leo_patient.update(athena_id: best_matched_patient.patientid.to_i)
      else
        @logger.info("Syncer: creating new Athena patient for leo patient.id=#{leo_patient.id}")
        should_update_athena_patient = false
        athena_patient_exists = leo_patient.athena_id = @connector.create_patient(to_athena_json leo_patient).to_i

        raise "Patient #{patient.id} failed to sync" unless athena_patient_exists

        leo_patient.save!
      end
    end

    if should_update_athena_patient
      put_patient(leo_patient)
    end

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

    leo_patient.patient_updated_at = DateTime.now.utc
    leo_patient.save!
  end

  private

  def get_athena_id(athena_patient)
    athena_patient["patientid"].try(:to_i)
  end

  def create_patient_enrollment(athena_patient)
    # TODO: handle guardians with no email
    enrollment_params = parse_athena_patient_json_to_guardian_enrollment(athena_patient)
    guardian_enrollment = Enrollment.create_with(enrollment_params).find_or_create_by(email: enrollment_params[:email])
    PatientEnrollment.create({guardian_enrollment: guardian_enrollment}.merge(parse_athena_patient_json_to_patient_enrollment(athena_patient))) if guardian_enrollment.id
  end

  def parse_athena_patient_json_to_guardian_enrollment(athena_patient)
    {
      first_name: athena_patient["guarantorfirstname"],
      last_name: athena_patient["guarantorlastname"],
      email: athena_patient["guarantoremail"],
      password: SecureRandom.urlsafe_base64(nil, false),
      phone: athena_patient["contactmobilephone"] ||
              athena_patient["homephone"] ||
              athena_patient["employerphone"] ||
              athena_patient["nextkinphone"],
      role: Role.guardian,
      vendor_id: GenericHelper.generate_vendor_id,
      onboarding_group: OnboardingGroup.find_by(group_name: :generated_from_athena)
    }
  end

  def parse_athena_patient_json_to_patient_enrollment(athena_patient)
    {
      first_name: athena_patient["firstname"],
      last_name: athena_patient["lastname"],
      birth_date: Date.strptime(athena_patient["dob"], "%m/%d/%Y"),
      sex: athena_patient["sex"],
      athena_id: get_athena_id(athena_patient)
    }
  end

  def to_athena_json(patient)
    parent = patient.family.primary_guardian
    patient_birth_date = patient.birth_date.strftime("%m/%d/%Y") if patient.birth_date
    parent_birth_date = parent.birth_date.strftime("%m/%d/%Y") if parent.birth_date

    guardians = patient.family.guardians.order('created_at ASC')
    contactname = nil
    contactrelationship = nil
    contactmobilephone = nil
    if guardians.size >= 2
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
