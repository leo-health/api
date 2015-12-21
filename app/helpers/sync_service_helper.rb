require "athena_health_api_helper"

module SyncService
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.start
    #make sure that the sync job is scheduled.  It will reschedule automatically.
    ProcessSyncTasksJob.schedule if Delayed::Job.table_exists?

    #create scan tasks
    SyncService.create_scan_tasks
  end

  def self.create_scan_tasks
    #create scan tasks
    if SyncService.configuration.auto_gen_scan_tasks && SyncTask.table_exists?
      SyncTask.find_or_create_by(sync_type: :scan_patients.to_s)
      SyncTask.find_or_create_by(sync_type: :scan_appointments.to_s)

      SyncService.configuration.department_ids.each { |id|
        SyncTask.find_or_create_by(sync_type: :scan_remote_appointments.to_s, sync_id: id)
      }
    end
  end

  class Configuration
    #Should ProcessSyncTasksJob reschedule itself on completion?
    #Set to true unless doing some kind of testing
    attr_accessor :auto_reschedule_job

    #Interval between successive runs of ProcessSyncTasksJob
    attr_accessor :job_interval

    #Should scanner tasks be auto-generated?  Scanner tasks scan the Leo DB and schedule SyncTasks for individual entities
    #Set to true unless doing testing.
    attr_accessor :auto_gen_scan_tasks

    #The interval between succesive patient data updates.
    attr_accessor :patient_data_interval

    #The interval between successive appointment updates
    attr_accessor :appointment_data_interval

    #An array of Athena department ids
    attr_accessor :department_ids

    def initialize
      @auto_reschedule_job = true
      @job_interval = 1.minutes
      @auto_gen_scan_tasks = true
      @patient_data_interval = 15.minutes
      @appointment_data_interval = 15.minutes
      @department_ids = [ 1 ]
    end
  end

  def self.create_debug_syncer(practice_id: 195900)
    connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(practice_id: practice_id)
    SyncServiceHelper::Syncer.new(connector)
  end
end

module SyncServiceHelper
  class Syncer
    @debug = false

    attr_reader :connector

    def initialize(connector)
      @connector = connector
    end

    # Process all sync tasks
    # Tasks that are completed will be removed from the table.  Tasks that failed
    # will stay.
    def process_all_sync_tasks()
      SyncTask.find_each() do |task|
        begin
          process_sync_task(task)

          #destroy task if everything went ok
          task.destroy
        rescue => e
          Rails.logger.error "Syncer: Processing sync task id=#{task.id} failed"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end
      end

      #re-create all the scan tasks
      SyncService.create_scan_tasks
    end

    # process a single sync task.  An exception will be thrown if anything goes wrong.
    #
    # ==== arguments
    # * +task+ - the sync task to process
    def process_sync_task(task)
      Rails.logger.info("Syncer: Processing task #{task.to_json}")
      if respond_to?("process_#{task.sync_type}")
        public_send("process_#{task.sync_type}", task)
      else
        raise "Unknown task.sync_type entry: #{task.sync_type}"
      end
    end

    # Go through all existing appointments and add all missing sync tasks for appointments.
    #
    # ==== arguments
    # * +task+ - the sync task to process
    def process_scan_appointments(task)
      Appointment.find_each do |appt|
        begin
          if appt.athena_id == 0
            SyncTask.find_or_create_by(sync_id: appt.id, sync_type: :appointment.to_s)
          else
            if appt.sync_updated_at.nil? || (appt.sync_updated_at.utc + SyncService.configuration.appointment_data_interval) < DateTime.now.utc
              SyncTask.find_or_create_by(sync_id: appt.id, sync_type: :appointment.to_s)
            end
          end

        rescue => e
          Rails.logger.error "Syncer: Creating sync task for appointment.id=#{appt.id} failed"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end

    def process_scan_remote_appointments(task)
      sync_params = {}
      sync_params = JSON.parse(task.sync_params) if task.sync_params.to_s != ''

      #mm/dd/yyyy hh:mi:ss
      start_date = nil
      start_date = DateTime.iso8601(sync_params[:start_date.to_s]).strftime("%m/%d/%Y %H:%M:00") if sync_params[:start_date.to_s]
      next_start_date = DateTime.now.to_s

      booked_appts = @connector.get_booked_appointments(
        departmentid: task.sync_id,
        startdate: 1.year.ago.strftime("%m/%d/%Y"),
        enddate: 1.year.from_now.strftime("%m/%d/%Y"),
        startlastmodified: start_date)

      booked_appts.each { |appt|
        leo_appt = Appointment.find_by(athena_id: appt.appointmentid.to_i)
        impl_create_leo_appt_from_athena(appt: appt) if leo_appt.nil?
      }

      #reschedule the task
      if SyncService.configuration.auto_gen_scan_tasks
        if SyncTask.where(sync_type: :scan_remote_appointments.to_s, sync_id: task.sync_id).where.not(id: task.id).count <= 0
          SyncTask.create(sync_type: :scan_remote_appointments.to_s, sync_id: task.sync_id, sync_params: { :start_date => next_start_date }.to_json)
        end
      end
    end

    def impl_create_leo_appt_from_athena(appt: )
      begin
        patient = Patient.find_by!(athena_id: appt.patientid.to_i)
        provider_profile = ProviderProfile.find_by!(athena_id: appt.providerid.to_i)
        appointment_type = AppointmentType.find_by!(athena_id: appt.appointmenttypeid.to_i)
        appointment_status = AppointmentStatus.find_by!(status: appt.appointmentstatus)

        Appointment.create(
          appointment_status: appointment_status,
          booked_by_id: provider_profile.provider.id,
          patient_id: patient.id,
          provider_id: provider_profile.provider.id,
          appointment_type_id: appointment_type.id,
          duration: appt.duration,
          start_datetime: Date.strptime("#{appt.date} #{appt.starttime}", "%m/%d/%Y %H:%M"),
          sync_updated_at: DateTime.now,
          athena_id: appt.appointmentid.to_i)
      rescue => e
          Rails.logger.error "Syncer: impl_create_leo_appt_from_athena appt=#{appt.to_json} failed"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
      end
    end

    def process_scan_patients(task)
      Patient.find_each do |patient|
        begin
          if patient.patient_updated_at.nil? || (patient.patient_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
            SyncTask.create_with(sync_source: :leo).find_or_create_by(sync_type: :patient.to_s, sync_id: patient.id)
          end

          if patient.photos_updated_at.nil? || (patient.photos_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
            SyncTask.create_with(sync_source: :leo).find_or_create_by(sync_type: :patient_photo.to_s, sync_id: patient.id)
          end

          if patient.allergies_updated_at.nil? || (patient.allergies_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
            SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_allergies.to_s, sync_id: patient.id)
          end

          if patient.insurances_updated_at.nil? || (patient.insurances_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
            SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_insurances.to_s, sync_id: patient.id)
          end

          if patient.medications_updated_at.nil? || (patient.medications_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
            SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_medications.to_s, sync_id: patient.id)
          end

          if patient.vaccines_updated_at.nil? || (patient.vaccines_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
            SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_vaccines.to_s, sync_id: patient.id)
          end

          if patient.vitals_updated_at.nil? || (patient.vitals_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
            SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_vitals.to_s, sync_id: patient.id)
          end
        rescue => e
          Rails.logger.error "Syncer: Creating sync task for patient user.id=#{user.id} failed"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end

    def process_appointment(task)
      leo_appt = Appointment.find(task.sync_id)

      #create appointment
      if leo_appt.athena_id == 0
        raise "Appointment appt.id=#{leo_appt.id} is in a state that cannot be reproduced in Athena" if leo_appt.open? || leo_appt.post_checked_in?
        raise "Appointment appt.id=#{leo_appt.id} is booked by a user that has not been synched yet" if leo_appt.patient.athena_id == 0
        raise "Appointment appt.id=#{leo_appt.id} is booked for a provider that does not have a provider_profile" if leo_appt.provider.provider_profile.nil?
        raise "Appointment appt.id=#{leo_appt.id} is booked for a provider_profile that does not have an athena_id" if leo_appt.provider.provider_profile.athena_id == 0
        raise "Appointment appt.id=#{leo_appt.id} is booked for a provider_profile that does not have an athena_department_id" if leo_appt.provider.provider_profile.athena_department_id == 0
        raise "Appointment appt.id=#{leo_appt.id} has an appointment type with invalid athena_id" if leo_appt.appointment_type.athena_id == 0

        #create appointment
        leo_appt.athena_id = @connector.create_appointment(
          appointmentdate: leo_appt.start_datetime.strftime("%m/%d/%Y"),
          appointmenttime: leo_appt.start_datetime.strftime("%H:%M"),
          appointmenttypeid: leo_appt.appointment_type.athena_id,
          departmentid: leo_appt.provider.provider_profile.athena_department_id,
          providerid: leo_appt.provider.provider_profile.athena_id
        )

        #book appointment
        @connector.book_appointment(
            appointmentid: leo_appt.athena_id,
            patientid: leo_appt.patient.athena_id,
            reasonid: nil,
            appointmenttypeid: leo_appt.appointment_type.athena_id,
            departmentid: leo_appt.provider.provider_profile.athena_department_id
        )

        leo_appt.save!
      end

      athena_appt = @connector.get_appointment(appointmentid: leo_appt.athena_id)
      raise "Could not find athena appointment with id=#{leo_appt.athena_id}" if athena_appt.nil?

      if athena_appt.future? && leo_appt.cancelled?
        #cancel
        @connector.cancel_appointment(appointmentid: leo_appt.athena_id,
          patientid: leo_appt.patient.athena_id) if athena_appt.booked?
      else
        #update from athena
        patient = Patient.find_by!(athena_id: athena_appt.patientid.to_i)
        provider_profile = ProviderProfile.find_by!(athena_id: athena_appt.providerid.to_i)
        appointment_type = AppointmentType.find_by!(athena_id: athena_appt.appointmenttypeid.to_i)
        appointment_status = AppointmentStatus.find_by(status: athena_appt.appointmentstatus)

        #athena does not return booked_by_id.  we have to leave it as is
        leo_appt.appointment_status = appointment_status
        leo_appt.patient_id = patient.id
        leo_appt.provider_id = provider_profile.provider.id
        leo_appt.appointment_type_id = appointment_type.id
        leo_appt.duration = athena_appt.duration.to_i
        leo_appt.start_datetime = Date.strptime(athena_appt.date + " " + athena_appt.starttime, "%m/%d/%Y %H:%M")
        leo_appt.athena_id = athena_appt.appointmentid.to_i

        #attempt to find rescheduled appt.  If not found, it will get updated on the next run.
        if athena_appt.respond_to? :rescheduledappointmentid
          rescheduled_appt = Appointment.find_by(athena_id: athena_appt.rescheduledappointmentid.to_i)
          leo_appt.rescheduled_id = rescheduled_appt.id if rescheduled_appt
        end
      end

      leo_appt.sync_updated_at = DateTime.now.utc
      leo_appt.save!
    end

    #sync patient
    #SyncTask.sync_id = User.id
    #creates an instance of HealthRecord model if one does not exist, and then updates the patient in Athena
    def process_patient(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient.id #{leo_patient.id} has no associated family" if leo_patient.family.nil?
      raise "patient.id #{leo_patient.id} has no primary_parent in his family" if leo_patient.family.primary_parent.nil?

      leo_parent = leo_patient.family.primary_parent

      Rails.logger.info("Syncer: synching patient=#{leo_patient.to_json}")

      patient_birth_date = leo_patient.birth_date.strftime("%m/%d/%Y") if leo_patient.birth_date
      parent_birth_date = leo_parent.birth_date.strftime("%m/%d/%Y") if leo_parent.birth_date

      if leo_patient.athena_id == 0
        #create patient
        leo_patient.athena_id = @connector.create_patient(
          departmentid: leo_parent.practice_id,
          firstname: leo_patient.first_name,
          middlename: leo_patient.middle_initial.to_s,
          lastname: leo_patient.last_name,
          sex: leo_patient.sex,
          dob: patient_birth_date,
          guarantorfirstname: leo_parent.first_name,
          guarantormiddlename: leo_parent.middle_initial.to_s,
          guarantorlastname: leo_parent.last_name,
          guarantordob: parent_birth_date,
          guarantoremail: leo_parent.email,
          guarantorrelationshiptopatient: 3 #3==child
          ).to_i
        leo_patient.save!
      else
        #update patient
        @connector.update_patient(
          patientid: leo_patient.athena_id,
          departmentid: leo_parent.practice_id,
          firstname: leo_patient.first_name,
          middlename: leo_patient.middle_initial.to_s,
          lastname: leo_patient.last_name,
          sex: leo_patient.sex,
          dob: patient_birth_date,
          guarantorfirstname: leo_parent.first_name,
          guarantormiddlename: leo_parent.middle_initial.to_s,
          guarantorlastname: leo_parent.last_name,
          guarantordob: parent_birth_date,
          guarantoremail: leo_parent.email,
          guarantorrelationshiptopatient: 3 #3==child
          )
      end

      #create insurance if not entered yet
      insurances = @connector.get_patient_insurances(patientid: leo_patient.athena_id)
      primary_insurance = insurances.find { |ins| ins[:sequencenumber.to_s].to_i == 1 }

      if primary_insurance.nil?
        insurance_plan = leo_parent.insurance_plan

        #only sync if the insurance plan is registered in athena
        if insurance_plan && insurance_plan.athena_id != 0
          @connector.create_patient_insurance(
            patientid: leo_patient.athena_id,
            insurancepackageid: insurance_plan.athena_id.to_s,
            insurancepolicyholderfirstname: leo_parent.first_name,
            insurancepolicyholderlastname: leo_parent.last_name,
            insurancepolicyholdermiddlename: leo_parent.middle_initial.to_s,
            insurancepolicyholdersex: leo_parent.sex,
            insurancepolicyholderdob: parent_birth_date,
            sequencenumber: 1.to_s
            )
        end
      end

      leo_patient.patient_updated_at = DateTime.now.utc
      leo_patient.save!
    end

    #sync patient photo
    #uploads the latest photo to athena, or deletes the athena photo if none found
    #SyncTask.sync_id = User.id
    def process_patient_photo(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_patient.athena_id == 0

      #get list of photos for this patients
      photos = leo_patient.photos.order("id desc")
      Rails.logger.info("Syncer: synching photos=#{photos.to_json}")

      if photos.empty?
        @connector.delete_patient_photo(patientid: leo_patient.athena_id)
      else
        @connector.set_patient_photo(patientid: leo_patient.athena_id, image: photos.first.image)
      end

      leo_patient.photos_updated_at = DateTime.now.utc
      leo_patient.save!
    end

    def process_patient_allergies(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_patient.athena_id == 0
      raise "patient.id #{leo_patient.id} has no primary_parent in his family" if leo_patient.family.primary_parent.nil?

      leo_parent = leo_patient.family.primary_parent

      #get list of allergies for this patients
      allergies = @connector.get_patient_allergies(patientid: leo_patient.athena_id, departmentid: leo_parent.practice_id)

      #remove existing allergies for the user
      Allergy.destroy_all(patient_id: leo_patient.id)

      #create and/or update the allergy records in Leo
      allergies.each do | allergy |
        leo_allergy = Allergy.find_or_create_by(patient_id: leo_patient.id, athena_id: allergy[:allergenid.to_s].to_i)

        leo_allergy.patient_id = leo_patient.id
        leo_allergy.athena_id = allergy[:allergenid.to_s].to_i
        leo_allergy.allergen = allergy[:allergenname.to_s]
        leo_allergy.onset_at = DateTime.strptime(allergy[:onsetdate.to_s], "%m/%d/%Y") if allergy[:onsetdate.to_s]

        reactions = []
        reactions = allergy[:reactions.to_s] if allergy[:reactions.to_s]
        leo_allergy.severity = reactions[0][:severity.to_s] if (reactions.size > 0 && reactions[0][:severity.to_s])

        leo_allergy.note = allergy[:note.to_s] if allergy[:note.to_s]

        leo_allergy.save!
      end

      leo_patient.allergies_updated_at = DateTime.now.utc
      leo_patient.save!
    end

    def process_patient_medications(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_patient.athena_id == 0
      raise "patient.id #{leo_patient.id} has no primary_parent in his family" if leo_patient.family.primary_parent.nil?

      leo_parent = leo_patient.family.primary_parent

      #get list of medications for this patients
      meds = @connector.get_patient_medications(patientid: leo_patient.athena_id, departmentid: leo_parent.practice_id)

      #remove existing medications for the user
      Medication.destroy_all(patient_id: leo_patient.id)

      #create and/or update the medication records in Leo
      meds.each do | med |
        leo_med = Medication.find_or_create_by(athena_id: med[:medicationid.to_s])

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
          leo_med.started_at = DateTime.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'START'.to_sym)
          leo_med.ended_at = DateTime.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'END'.to_sym)
          leo_med.ordered_at = DateTime.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'ORDER'.to_sym)
          leo_med.filled_at = DateTime.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'FILL'.to_sym)
          leo_med.entered_at = DateTime.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'ENTER'.to_sym)
          leo_med.hidden_at = DateTime.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'HIDE'.to_sym)
        end

        leo_med.save!
      end

      leo_patient.medications_updated_at = DateTime.now.utc
      leo_patient.save!
    end

    def process_patient_vitals(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_patient.athena_id == 0
      raise "patient.id #{leo_patient.id} has no primary_parent in his family" if leo_patient.family.primary_parent.nil?

      leo_parent = leo_patient.family.primary_parent

      #get list of vitals for this patients
      vitals = @connector.get_patient_vitals(patientid: leo_patient.athena_id, departmentid: leo_parent.practice_id)

      #remove existing vitals for the user
      Vital.destroy_all(patient_id: leo_patient.id)

      #create and/or update the vitals records in Leo
      vitals.each do | vital |
        vital[:readings.to_s].each do | reading_arr |
          reading = reading_arr[0]

          leo_vital = Vital.find_or_create_by(athena_id: reading[:vitalid.to_s].to_i)

          leo_vital.patient_id = leo_patient.id
          leo_vital.athena_id = reading[:vitalid.to_s].to_i
          leo_vital.measurement = reading[:clinicalelementid.to_s]
          leo_vital.value = reading[:value.to_s]
          leo_vital.taken_at = DateTime.strptime(reading[:readingtaken.to_s], "%m/%d/%Y") if reading[:readingtaken.to_s]

          leo_vital.save!
        end
      end

      leo_patient.vitals_updated_at = DateTime.now.utc
      leo_patient.save!
    end

    def process_patient_vaccines(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_patient.athena_id == 0
      raise "patient.id #{leo_patient.id} has no primary_parent in his family" if leo_patient.family.primary_parent.nil?

      leo_parent = leo_patient.family.primary_parent

      #get list of vaccines for this patients
      vaccs = @connector.get_patient_vaccines(patientid: leo_patient.athena_id, departmentid: leo_parent.practice_id)

      #remove existing vaccines for the user
      Vaccine.destroy_all(patient_id: leo_patient.id)

      #create and/or update the vaccine records in Leo
      vaccs.each do | vacc |
        if vacc[:status.to_s] == 'ADMINISTERED'
          leo_vacc = Vaccine.find_or_create_by(athena_id: vacc[:vaccineid.to_s])

          leo_vacc.patient_id = leo_patient.id
          leo_vacc.athena_id = vacc[:vaccineid.to_s]
          leo_vacc.vaccine = vacc[:description.to_s]
          leo_vacc.administered_at = DateTime.strptime(vacc[:administerdate.to_s], "%m/%d/%Y") if vacc[:administerdate.to_s]

          leo_vacc.save!
        end
      end

      leo_patient.vaccines_updated_at = DateTime.now.utc
      leo_patient.save!
    end

    def process_patient_insurances(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_patient.athena_id == 0
      raise "patient.id #{leo_patient.id} has no primary_parent in his family" if leo_patient.family.primary_parent.nil?

      leo_parent = leo_patient.family.primary_parent

      #get list of insurances for this patient
      insurances = @connector.get_patient_insurances(patientid: leo_patient.athena_id)

      #remove existing insurances for the user
      Insurance.destroy_all(patient_id: leo_patient.id)

      #create and/or update the vaccine records in Leo
      insurances.each do | insurance |
        leo_insurance = Insurance.create_with(irc_name: insurance[:ircname.to_s]).find_or_create_by(athena_id: insurance[:insuranceid.to_s].to_i)

        leo_insurance.patient_id = leo_patient.id
        leo_insurance.athena_id = insurance[:insuranceid.to_s].to_i
        leo_insurance.plan_name = insurance[:insuranceplanname.to_s]
        leo_insurance.plan_phone = insurance[:insurancephone.to_s]
        leo_insurance.plan_type = insurance[:insurancetype.to_s]
        leo_insurance.policy_number = insurance[:policynumber.to_s]
        leo_insurance.holder_ssn = insurance[:insurancepolicyholderssn.to_s]
        leo_insurance.holder_birth_date = insurance[:insurancepolicyholderdob.to_s]
        leo_insurance.holder_sex = insurance[:insurancepolicyholdersex.to_s]
        leo_insurance.holder_last_name = insurance[:insurancepolicyholderlastname.to_s]
        leo_insurance.holder_first_name = insurance[:insurancepolicyholderfirstname.to_s]
        leo_insurance.holder_middle_name = insurance[:insurancepolicyholdermiddlename.to_s]
        leo_insurance.holder_address_1 = insurance[:insurancepolicyholderaddress1.to_s]
        leo_insurance.holder_address_2 = insurance[:insurancepolicyholderaddress2.to_s]
        leo_insurance.holder_city = insurance[:insurancepolicyholdercity.to_s]
        leo_insurance.holder_state = insurance[:insurancepolicyholderstate.to_s]
        leo_insurance.holder_zip = insurance[:insurancepolicyholderzip.to_s]
        leo_insurance.holder_country = insurance[:insurancepolicyholdercountrycode.to_s]
        leo_insurance.primary = insurance[:sequencenumber.to_s]
        leo_insurance.irc_name = insurance[:ircname.to_s]

        leo_insurance.save!
      end

      leo_patient.insurances_updated_at = DateTime.now.utc
      leo_patient.save!
    end
  end
end
