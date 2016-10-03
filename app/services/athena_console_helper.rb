# NOTE: These methods are currently not used in code, but meant to be run manually from rails console
class AthenaConsoleHelper < AthenaSyncService
  def get_patients_with_guarantor_email(practice:, email:)
    @connector.get_patients(
      departmentid: practice.athena_id,
      guarantoremail: email
    )
  end

  def get_all_patients(practice, verbose: false, exempt: false)
    puts "Getting all patients with departmentid #{practice.athena_id}" if verbose
    all_athena_patients = @connector.get_patients(departmentid: practice.athena_id).sort_by { |athena_patient| get_athena_id(athena_patient) }
    puts "Athena returned #{all_athena_patients.count} patients" if verbose

    # only sync patients whose guardian is included in the list
    guardian_emails = File.readlines('lib/assets/exempt_guardian_emails.txt').map(&:strip).map(&:downcase)
    athena_patients = all_athena_patients.select do |patient|
      should_select = guardian_emails.include? patient["guarantoremail"].try(:downcase)
      should_select &&= dob_s = patient["dob"]
      should_select &&= dob = Time.strptime(dob_s, "%m/%d/%Y")
      should_select &&= (Time.now - dob) < 13.years
    end

    athena_ids = athena_patients.map { |athena_patient| get_athena_id(athena_patient) }
    existing_athena_ids = Patient.where(athena_id: athena_ids).order(:athena_id).pluck(:athena_id).to_enum
    puts "Of which we already have #{existing_athena_ids.count} in Leo" if verbose
    puts "Will create #{athena_ids.count - existing_athena_ids.count} patients in Leo" if verbose

    {athena_patients: athena_patients, guardian_emails: guardian_emails, all_athena_patients: all_athena_patients}
  end

  def sync_all_patients(athena_patients, verbose: false)
    athena_ids = athena_patients.map { |athena_patient| get_athena_id(athena_patient) }
    existing_athena_ids = Patient.where(athena_id: athena_ids).order(:athena_id).pluck(:athena_id).to_enum
    puts "Of which we already have #{existing_athena_ids.count} in Leo" if verbose
    puts "Will create #{athena_ids.count - existing_athena_ids.count} patients in Leo" if verbose

    next_existing_athena_id = nil
    patients = athena_patients.reduce([]) { |created_patients, athena_patient|
      begin
        next_existing_athena_id ||= existing_athena_ids.next
      rescue StopIteration
      end

      patient_already_exists = get_athena_id(athena_patient) == next_existing_athena_id
      if patient_already_exists
        next_existing_athena_id = nil
      elsif created_patient = create_leo_patient_from_athena_patient(athena_patient, verbose: verbose, exempt: exempt)
        created_patients << created_patient
      end

      created_patients
    }
    puts "Created #{patients.count} patients" if verbose
    patients
  end

  private

  def get_athena_id(athena_patient)
    athena_patient["patientid"].try(:to_i)
  end

  def create_leo_patient_from_athena_patient(athena_patient, verbose: false, exempt: false)
    user_params = parse_athena_patient_json_to_guardian(athena_patient)

    guardian = User.find_by_email(user_params[:email])
    unless guardian
      User.transaction do
        guardian = User.create!(user_params)
        guardian.family.exempt_membership! if exempt
      end
    end
    return nil unless guardian

    patient = Patient.create({family: guardian.family}.merge(parse_athena_patient_json_to_patient(athena_patient)))
    puts "Created patient leo_id: #{patient.id}, athena_id: #{patient.athena_id}" if verbose
    patient
  end

  def parse_athena_patient_json_to_guardian(athena_patient)
    {
      email: athena_patient["guarantoremail"],
      role: Role.guardian,
      onboarding_group: OnboardingGroup.generated_from_athena
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
end
