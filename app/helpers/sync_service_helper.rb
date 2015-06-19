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
    if SyncService.configuration.auto_gen_scan_tasks
      SyncTask.find_or_create_by(sync_type: :scan_patients.to_s) if SyncTask.table_exists?
    end

    if SyncService.configuration.auto_gen_scan_tasks
      SyncTask.find_or_create_by(sync_type: :scan_appointments.to_s) if SyncTask.table_exists?
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

    def initialize
      @auto_reschedule_job = true
      @job_interval = 1.minutes
      @auto_gen_scan_tasks = true
      @patient_data_interval = 15.minutes
      @appointment_data_interval = 15.minutes
    end
  end

  def self.create_debug_syncer(practice_id: 195900)
    connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new(practice_id: practice_id)
    syncer = SyncServiceHelper::Syncer.new(connector)

    return syncer
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

      if task.sync_type  == :appointment.to_s
        process_appointment(task)
      elsif task.sync_type  == :scan_appointments.to_s
        process_scan_appointments(task)
      elsif task.sync_type  == :scan_patients.to_s
        process_scan_patients(task)
      elsif task.sync_type  == :patient.to_s
        process_patient(task)
      elsif task.sync_type  == :patient_photo.to_s
        process_patient_photo(task)
      elsif task.sync_type  == :patient_allergies.to_s
        process_patient_allergies(task)
      elsif task.sync_type  == :patient_medications.to_s
        process_patient_medications(task)
      elsif task.sync_type  == :patient_vaccines.to_s
        process_patient_vaccines(task)
      elsif task.sync_type  == :patient_vitals.to_s
        process_patient_vitals(task)
      elsif task.sync_type  == :patient_insurances.to_s
        process_patient_insurances(task)
      else
        raise "Unknown task.sync_type entry: #{task.sync_type}"
      end
    end

    # Go through all existing appointments and add all missing sync tasks for appointments.
    #
    # ==== arguments
    # * +task+ - the sync task to process
    def process_scan_appointments(task)
      Appointment.find_each() do |appt|
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

    def process_scan_patients(task)
      User.find_each() do |user|
        if user.has_role? :child
          begin
            if user.patient.nil?
              SyncTask.create_with(sync_source: :leo).find_or_create_by(sync_type: :patient.to_s, sync_id: user.id)
              SyncTask.create_with(sync_source: :leo).find_or_create_by(sync_type: :patient_photo.to_s, sync_id: user.id)
              SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_allergies.to_s, sync_id: user.id)
              SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_insurances.to_s, sync_id: user.id)
              SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_medications.to_s, sync_id: user.id)
              SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_vaccines.to_s, sync_id: user.id)
              SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_vitals.to_s, sync_id: user.id)
            else
              if user.patient.patient_updated_at.nil? || (user.patient.patient_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
                SyncTask.create_with(sync_source: :leo).find_or_create_by(sync_type: :patient.to_s, sync_id: user.id)
              end

              if user.patient.photos_updated_at.nil? || (user.patient.photos_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
                SyncTask.create_with(sync_source: :leo).find_or_create_by(sync_type: :patient_photo.to_s, sync_id: user.id)
              end

              if user.patient.allergies_updated_at.nil? || (user.patient.allergies_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
                SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_allergies.to_s, sync_id: user.id)
              end

              if user.patient.insurances_updated_at.nil? || (user.patient.insurances_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
                SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_insurances.to_s, sync_id: user.id)
              end

              if user.patient.medications_updated_at.nil? || (user.patient.medications_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
                SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_medications.to_s, sync_id: user.id)
              end

              if user.patient.vaccines_updated_at.nil? || (user.patient.vaccines_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
                SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_vaccines.to_s, sync_id: user.id)
              end

              if user.patient.vitals_updated_at.nil? || (user.patient.vitals_updated_at.utc + SyncService.configuration.patient_data_interval) < DateTime.now.utc
                SyncTask.create_with(sync_source: :athena).find_or_create_by(sync_type: :patient_vitals.to_s, sync_id: user.id)
              end
            end
          rescue => e 
            Rails.logger.error "Syncer: Creating sync task for patient user.id=#{user.id} failed"
            Rails.logger.error e.message
            Rails.logger.error e.backtrace.join("\n")
          end
        end
      end
    end

    def process_appointment(task)
      leo_appt = Appointment.find(task.sync_id)

      #create appointment
      if leo_appt.athena_id == 0
        raise "Appointment appt.id=#{leo_appt.id} is in a state that cannot be reproduced in Athena" if leo_appt.open? || leo_appt.post_checked_in?
        raise "Appointment appt.id=#{leo_appt.id} is booked by a user that has not been synched yet" if leo_appt.leo_patient.patient.nil? || leo_appt.leo_patient.patient.athena_id == 0
        raise "Appointment appt.id=#{leo_appt.id} does not have a valid athena_provider_id" if leo_appt.athena_provider_id == 0
        raise "Appointment appt.id=#{leo_appt.id} does not have a valid athena_department_id" if leo_appt.athena_department_id == 0
        raise "Appointment appt.id=#{leo_appt.id} does not have a valid athena_appointment_type_id" if leo_appt.athena_appointment_type_id == 0

        #create appointment
        leo_appt.athena_id = @connector.create_appointment(
          appointmentdate: leo_appt.appointment_date.strftime("%m/%d/%Y"),
          appointmenttime: leo_appt.appointment_start_time.strftime("%H:%M"), 
          appointmenttypeid: leo_appt.athena_appointment_type_id,
          departmentid: leo_appt.athena_department_id,
          providerid: leo_appt.athena_provider_id
        )

        #book appointment
        @connector.book_appointment(
            appointmentid: leo_appt.athena_id,
            patientid: leo_appt.leo_patient.patient.athena_id,
            reasonid: nil,
            appointmenttypeid: leo_appt.athena_appointment_type_id,
            departmentid: leo_appt.athena_department_id
        )

        leo_appt.save!
      end

      athena_appt = @connector.get_appointment(appointmentid: leo_appt.athena_id)
      raise "Could not find athena appointment with id=#{leo_appt.athena_id}" if athena_appt.nil?

      @connector.freeze_appointment(appointmentid:leo_appt.athena_id, freeze: leo_appt.frozenyn)

      if athena_appt.future? && leo_appt.cancelled?
        if leo_appt.rescheduled_appointment_id
          #reschedule
          leo_resched_appt = Appointment.find(leo_appt.rescheduled_appointment_id)
          raise "Could not find rescheduled leo appt id: #{leo_appt.rescheduled_appointment_id}" if leo_resched_appt.nil?

          if leo_resched_appt.athena_id == 0
            process_appointment(SynchTask.new(sync_type: :appointment.to_s, sync_id: leo_appt.rescheduled_appointment_id))
          end
          leo_resched_appt = Appointment.find(leo_appt.rescheduled_appointment_id)

          @connector.reschedule_appointment(
            appointmentid: leo_appt.athena_id,
            newappointmentid: leo_resched_appt.athena_id, 
            patientid: leo_appt.leo_patient.patient.athena_id
          )
        else
          #cancel
          @connector.cancel_appointment(appointmentid: leo_appt.athena_id, 
            patientid: leo_appt.leo_patient.patient.athena_id) if athena_appt.booked?
        end
      else
        leo_appt.appointment_status = athena_appt.appointmentstatus

        leo_appt.athena_appointment_type = athena_appt.appointmenttype
        #todo: do we need to update leo_appointment_type
        leo_appt.athena_provider_id = athena_appt.providerid.to_i
        #todo: do we need to update leo_provider_id
        leo_appt.athena_department_id = athena_appt.departmentid.to_i
        leo_appt.athena_appointment_type_id = athena_appt.appointmenttypeid.to_i

        #todo: any other stuff that would need to get synched back to leo
        #the following should not change from athena side
        #todo: do we need to update leo_patient_id
        #rescheduled_appointment_id = athena_appt.rescheduledappointmentid
        #duration = athena_appt.duration
        #appointment_date = 
        #appointment_start_time = 
        #frozenyn = athena_appt.frozenyn
      end

      leo_appt.sync_updated_at = DateTime.now.utc
      leo_appt.save!
    end

    def create_leo_user_from_athena_patient(patientid: )
      leo_patient = Patient.find_by(athena_id: patientid)
      raise "Patient id=#{patientid} already exists in Leo" unless leo_patient.nil?

      athena_patient = @connector.get_patient(patientid: patientid)
      raise "No patient found for id=#{patientid}" unless athena_patient

      #create family
      family = Family.create()

      #create patient user
      child = User.create(
        first_name: athena_patient.firstname,
        middle_initial: '',
        last_name: athena_patient.lastname,
        practice_id: athena_patient.departmentid,
        sex: athena_patient.sex,
        dob: DateTime.strptime(athena_patient.dob, "%m/%d/%Y"),
        password: 'fake_pass',
        password_confirmation: 'fake_pass',
        email: Random.rand().to_s + '@leohealth.com',
        family_id: family.id
        )

      child.add_role :child
      child.save!

      Patient.create(user_id: child.id, athena_id: patientid)

      #create parent user
      parent = User.create(
        first_name: athena_patient.firstname + 'Parent',
        middle_initial: '',
        last_name: athena_patient.lastname + 'Parent',
        practice_id: athena_patient.departmentid,
        sex: athena_patient.sex,
        dob: 45.years.ago,
        password: 'fake_pass',
        password_confirmation: 'fake_pass',
        email: Random.rand().to_s + '@leohealth.com',
        family_id: family.id
        )

      parent.add_role :parent
      parent.save!

      return child
    end

    #sync patient
    #SyncTask.sync_id = User.id
    #creates an instance of Patient model if one does not exist, and then updates the patient in Athena
    def process_patient(task)
      leo_user = User.find(task.sync_id)

      #only need to create patient if the user has the role child
      if leo_user.has_role? :child
        raise "user.id #{leo_user.id} has no associated family" if leo_user.family.nil?
        raise "user.id #{leo_user.id} has no parents in his family" if leo_user.family.parents.empty?

        leo_parent = leo_user.family.parents.first

        leo_patient = nil

        begin
          leo_patient = Patient.find_or_create_by(user_id: task.sync_id)
        rescue => e 
          Rails.logger.error "Syncer: Creating patient for user.id=#{task.sync_id} failed"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end

        Rails.logger.info("Syncer: synching patient=#{leo_patient.to_json}")
      
        patient_dob = leo_user.dob.strftime("%m/%d/%Y") if leo_user.dob
        parent_dob = leo_parent.dob.strftime("%m/%d/%Y") if leo_parent.dob

        if leo_patient.athena_id == 0
          #create patient
          leo_patient.athena_id = @connector.create_patient(
            departmentid: leo_user.practice_id, 
            firstname: leo_user.first_name, 
            middlename: leo_user.middle_initial.to_s, 
            lastname: leo_user.last_name, 
            sex: leo_user.sex, 
            dob: patient_dob,
            guarantorfirstname: leo_parent.first_name, 
            guarantormiddlename: leo_parent.middle_initial.to_s, 
            guarantorlastname: leo_parent.last_name, 
            guarantordob: parent_dob, 
            guarantoremail: leo_parent.email,
            guarantorrelationshiptopatient: 3 #3==child
            ).to_i
          leo_patient.save!
        else
          #update patient
          @connector.update_patient(
            patientid: leo_patient.athena_id, 
            departmentid: leo_user.practice_id, 
            firstname: leo_user.first_name, 
            middlename: leo_user.middle_initial.to_s, 
            lastname: leo_user.last_name, 
            sex: leo_user.sex, 
            dob: patient_dob,
            guarantorfirstname: leo_parent.first_name, 
            guarantormiddlename: leo_parent.middle_initial.to_s, 
            guarantorlastname: leo_parent.last_name, 
            guarantordob: parent_dob, 
            guarantoremail: leo_parent.email,
            guarantorrelationshiptopatient: 3 #3==child
            )
        end

        leo_patient.patient_updated_at = DateTime.now.utc
        leo_patient.save!
      end
    end

    #sync patient photo
    #uploads the latest photo to athena, or deletes the athena photo if none found
    #SyncTask.sync_id = User.id
    def process_patient_photo(task)
      leo_user = User.find(task.sync_id)

      raise "missing patient associated with user.id=#{task.sync_id}" if leo_user.patient.nil?
      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_user.patient.athena_id == 0

      #get list of photos for this patients
      photos = leo_user.patient.photos.order("id desc")
      Rails.logger.info("Syncer: synching photos=#{photos.to_json}")

      if photos.empty?
        @connector.delete_patient_photo(patientid: leo_user.patient.athena_id)
      else
        @connector.set_patient_photo(patientid: leo_user.patient.athena_id, image: photos.first.image)
      end

      leo_user.patient.photos_updated_at = DateTime.now.utc
      leo_user.patient.save!
    end

    def process_patient_allergies(task)
      leo_user = User.find(task.sync_id)

      raise "missing patient associated with user.id=#{task.sync_id}" if leo_user.patient.nil?
      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_user.patient.athena_id == 0

      #get list of allergies for this patients
      allergies = @connector.get_patient_allergies(patientid: leo_user.patient.athena_id, departmentid: leo_user.practice_id)

      #remove existing allergies for the user
      Allergy.destroy_all(patient_id: leo_user.patient.id)

      #create and/or update the allergy records in Leo
      allergies.each do | allergy |
        leo_allergy = Allergy.find_or_create_by(patient_id: leo_user.patient.id, athena_id: allergy[:allergenid.to_s].to_i)

        leo_allergy.patient_id = leo_user.patient.id
        leo_allergy.athena_id = allergy[:allergenid.to_s].to_i
        leo_allergy.allergen = allergy[:allergenname.to_s]
        leo_allergy.onset_at = DateTime.strptime(allergy[:onsetdate.to_s], "%m/%d/%Y") if allergy[:onsetdate.to_s]

        leo_allergy.save!
      end

      leo_user.patient.allergies_updated_at = DateTime.now.utc
      leo_user.patient.save!
    end

    def process_patient_medications(task)
      leo_user = User.find(task.sync_id)

      raise "missing patient associated with user.id=#{task.sync_id}" if leo_user.patient.nil?
      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_user.patient.athena_id == 0

      #get list of medications for this patients
      meds = @connector.get_patient_medications(patientid: leo_user.patient.athena_id, departmentid: leo_user.practice_id)

      #remove existing medications for the user
      Medication.destroy_all(patient_id: leo_user.patient.id)

      #create and/or update the medication records in Leo
      meds.each do | med |
        leo_med = Medication.find_or_create_by(athena_id: med[:medicationid.to_s])

        leo_med.patient_id = leo_user.patient.id
        leo_med.athena_id = med[:medicationid.to_s]
        leo_med.medication = med[:medication.to_s]
        leo_med.sig = med[:unstructuredsig.to_s]
        leo_med.sig ||= ''
        leo_med.patient_note = med[:patientnote.to_s]
        leo_med.patient_note ||= ''
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

      leo_user.patient.medications_updated_at = DateTime.now.utc
      leo_user.patient.save!
    end

    def process_patient_vitals(task)
      leo_user = User.find(task.sync_id)

      raise "missing patient associated with user.id=#{task.sync_id}" if leo_user.patient.nil?
      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_user.patient.athena_id == 0

      #get list of vitals for this patients
      vitals = @connector.get_patient_vitals(patientid: leo_user.patient.athena_id, departmentid: leo_user.practice_id)

      #remove existing vitals for the user
      Vital.destroy_all(patient_id: leo_user.patient.id)

      #create and/or update the vitals records in Leo
      vitals.each do | vital |
        vital[:readings.to_s].each do | reading_arr |
          reading = reading_arr[0]
          
          leo_vital = Vital.find_or_create_by(athena_id: reading[:vitalid.to_s].to_i)

          leo_vital.patient_id = leo_user.patient.id
          leo_vital.athena_id = reading[:vitalid.to_s].to_i
          leo_vital.measurement = reading[:clinicalelementid.to_s]
          leo_vital.value = reading[:value.to_s]
          leo_vital.taken_at = DateTime.strptime(reading[:readingtaken.to_s], "%m/%d/%Y") if reading[:readingtaken.to_s]

          leo_vital.save!
        end
      end

      leo_user.patient.vitals_updated_at = DateTime.now.utc
      leo_user.patient.save!
    end

    def process_patient_vaccines(task)
      leo_user = User.find(task.sync_id)

      raise "missing patient associated with user.id=#{task.sync_id}" if leo_user.patient.nil?
      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_user.patient.athena_id == 0

      #get list of vaccines for this patients
      vaccs = @connector.get_patient_vaccines(patientid: leo_user.patient.athena_id, departmentid: leo_user.practice_id)

      #remove existing vaccines for the user
      Vaccine.destroy_all(patient_id: leo_user.patient.id)

      #create and/or update the vaccine records in Leo
      vaccs.each do | vacc |
        if vacc[:status.to_s] == 'ADMINISTERED'
          leo_vacc = Vaccine.find_or_create_by(athena_id: vacc[:vaccineid.to_s])

          leo_vacc.patient_id = leo_user.patient.id
          leo_vacc.athena_id = vacc[:vaccineid.to_s]
          leo_vacc.vaccine = vacc[:description.to_s]
          leo_vacc.administered_at = DateTime.strptime(vacc[:administerdate.to_s], "%m/%d/%Y") if vacc[:administerdate.to_s]

          leo_vacc.save!
        end
      end

      leo_user.patient.vaccines_updated_at = DateTime.now.utc
      leo_user.patient.save!
    end

    def process_patient_insurances(task)
      leo_user = User.find(task.sync_id)

      raise "missing patient associated with user.id=#{task.sync_id}" if leo_user.patient.nil?
      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_user.patient.athena_id == 0

      #get list of insurances for this patient
      insurances = @connector.get_patient_insurances(patientid: leo_user.patient.athena_id)

      #remove existing insurances for the user
      Insurance.destroy_all(patient_id: leo_user.patient.id)

      #create and/or update the vaccine records in Leo
      insurances.each do | insurance |
        leo_insurance = Insurance.find_or_create_by(athena_id: insurance[:insuranceid.to_s].to_i)

        leo_insurance.patient_id = leo_user.patient.id
        leo_insurance.athena_id = insurance[:insuranceid.to_s].to_i
        leo_insurance.plan_name = insurance[:insuranceplanname.to_s]
        leo_insurance.plan_phone = insurance[:insurancephone.to_s]
        leo_insurance.plan_type = insurance[:insurancetype.to_s]
        leo_insurance.policy_number = insurance[:policynumber.to_s]
        leo_insurance.holder_ssn = insurance[:insurancepolicyholderssn.to_s]
        leo_insurance.holder_dob = insurance[:insurancepolicyholderdob.to_s]
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

        leo_insurance.save!
      end

      leo_user.patient.insurances_updated_at = DateTime.now.utc
      leo_user.patient.save!
    end
  end
end

