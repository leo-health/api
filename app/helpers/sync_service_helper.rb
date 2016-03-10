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
      SyncTask.find_or_create_by(sync_type: :scan_providers.to_s)

      Practice.find_each { |practice|
        SyncTask.find_or_create_by(sync_type: :scan_remote_appointments.to_s, sync_id: practice.athena_id)        
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

    #logger
    attr_accessor :logger

    def initialize
      @auto_reschedule_job = true
      @job_interval = 1.minutes
      @auto_gen_scan_tasks = true
      @patient_data_interval = 15.minutes
      @appointment_data_interval = 15.minutes
      @logger = Rails.logger
    end
  end
end

module SyncServiceHelper
  class Syncer
    attr_reader :connector

    def initialize(connector = AthenaHealthApiHelper::AthenaHealthApiConnector.new)
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
          SyncService.configuration.logger.error "Syncer: Processing sync task id=#{task.id} failed"
          SyncService.configuration.logger.error e.message
          SyncService.configuration.logger.error e.backtrace.join("\n")
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
      SyncService.configuration.logger.info("Syncer: Processing task #{task.to_json}")
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
          SyncService.configuration.logger.error "Syncer: Creating sync task for appointment.id=#{appt.id} failed"
          SyncService.configuration.logger.error e.message
          SyncService.configuration.logger.error e.backtrace.join("\n")
        end
      end
    end

    # Go through all existing providers and add all missing sync tasks for providers.
    #
    # ==== arguments
    # * +task+ - the sync task to process
    def process_scan_providers(task)
      ProviderSyncProfile.find_each do |provider_sync_profile|
        begin
          if provider_sync_profile.leave_updated_at.nil? || (provider_sync_profile.leave_updated_at.utc + SyncService.configuration.appointment_data_interval) < DateTime.now.utc
            SyncTask.find_or_create_by(sync_id: provider_sync_profile.provider_id, sync_type: :provider_leave.to_s)
          end

        rescue => e
          SyncService.configuration.logger.error "Syncer: Creating sync task for provider.id=#{provider_sync_profile.provider_id} failed"
          SyncService.configuration.logger.error e.message
          SyncService.configuration.logger.error e.backtrace.join("\n")
        end
      end
    end

    def process_scan_remote_appointments(task)
      sync_params = {}
      sync_params = JSON.parse(task.sync_params) if task.sync_params.to_s != ''

      #mm/dd/yyyy hh:mi:ss
      start_date = nil
      start_date = DateTime.parse(sync_params[:start_date.to_s]) if sync_params[:start_date.to_s]
      start_last_modified = nil
      start_last_modified = start_date.strftime("%m/%d/%Y") if start_date
      next_start_date = DateTime.now.to_s

      booked_appts = @connector.get_booked_appointments(
        departmentid: task.sync_id,
        startdate: 1.year.ago.strftime("%m/%d/%Y"),
        enddate: 1.year.from_now.strftime("%m/%d/%Y"),
        startlastmodified: start_last_modified
      )

      booked_appts.each { |appt|
        leo_appt = Appointment.find_by(athena_id: appt.appointmentid.to_i)
        impl_create_leo_appt_from_athena(appt: appt) unless leo_appt
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
        provider_sync_profile = ProviderSyncProfile.find_by!(athena_id: appt.providerid.to_i)
        appointment_type = AppointmentType.find_by!(athena_id: appt.appointmenttypeid.to_i)
        appointment_status = AppointmentStatus.find_by!(status: appt.appointmentstatus)
        Appointment.create!(
          appointment_status: appointment_status,
          booked_by: provider_sync_profile.provider,
          patient: patient,
          provider: provider_sync_profile.provider,
          appointment_type: appointment_type,
          duration: appt.duration,
          start_datetime: AthenaHealthApiHelper.to_datetime(appt.date, appt.starttime),
          sync_updated_at: DateTime.now,
          athena_id: appt.appointmentid.to_i
        )
      rescue => e
          SyncService.configuration.logger.error "Syncer: impl_create_leo_appt_from_athena appt=#{appt.to_json} failed"
          SyncService.configuration.logger.error e.message
          SyncService.configuration.logger.error e.backtrace.join("\n")
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
          SyncService.configuration.logger.error "Syncer: Creating sync task for patient user.id=#{user.id} failed"
          SyncService.configuration.logger.error e.message
          SyncService.configuration.logger.error e.backtrace.join("\n")
        end
      end
    end

    def process_appointment(task)
      leo_appt = Appointment.find(task.sync_id)

      #create appointment
      if leo_appt.athena_id == 0
        raise "Appointment appt.id=#{leo_appt.id} is in a state that cannot be reproduced in Athena" if leo_appt.open? || leo_appt.post_checked_in?
        raise "Appointment appt.id=#{leo_appt.id} is booked by a user that has not been synched yet" if leo_appt.patient.athena_id == 0
        raise "Appointment appt.id=#{leo_appt.id} is booked for a provider that does not have a provider_sync_profile" unless leo_appt.provider.provider_sync_profile
        raise "Appointment appt.id=#{leo_appt.id} is booked for a provider_sync_profile that does not have an athena_id" if leo_appt.provider.provider_sync_profile.athena_id == 0
        raise "Appointment appt.id=#{leo_appt.id} is booked for a provider_sync_profile that does not have an athena_department_id" if leo_appt.provider.provider_sync_profile.athena_department_id == 0
        raise "Appointment appt.id=#{leo_appt.id} has an appointment type with invalid athena_id" if leo_appt.appointment_type.athena_id == 0

        #create appointment
        leo_appt.athena_id = @connector.create_appointment(
          appointmentdate: leo_appt.start_datetime.strftime("%m/%d/%Y"),
          appointmenttime: leo_appt.start_datetime.strftime("%H:%M"),
          appointmenttypeid: leo_appt.appointment_type.athena_id,
          departmentid: leo_appt.provider.provider_sync_profile.athena_department_id,
          providerid: leo_appt.provider.provider_sync_profile.athena_id
        )

        #book appointment
        @connector.book_appointment(
            appointmentid: leo_appt.athena_id,
            patientid: leo_appt.patient.athena_id,
            reasonid: nil,
            appointmenttypeid: leo_appt.appointment_type.athena_id,
            departmentid: leo_appt.provider.provider_sync_profile.athena_department_id
        )

        #add appointment notes
        if leo_appt.notes
          @connector.create_appointment_note(appointmentid: leo_appt.athena_id, notetext: leo_appt.notes)
        end

        leo_appt.save!
      end

      athena_appt = @connector.get_appointment(appointmentid: leo_appt.athena_id)
      raise "Could not find athena appointment with id=#{leo_appt.athena_id}" unless athena_appt

      if athena_appt.future? && leo_appt.cancelled?
        #cancel
        @connector.cancel_appointment(appointmentid: leo_appt.athena_id,
          patientid: leo_appt.patient.athena_id) if athena_appt.booked?
      else
        #update from athena
        patient = Patient.find_by!(athena_id: athena_appt.patientid.to_i)
        provider_sync_profile = ProviderSyncProfile.find_by!(athena_id: athena_appt.providerid.to_i)
        appointment_type = AppointmentType.find_by!(athena_id: athena_appt.appointmenttypeid.to_i)
        appointment_status = AppointmentStatus.find_by(status: athena_appt.appointmentstatus)

        #athena does not return booked_by_id.  we have to leave it as is
        leo_appt.appointment_status = appointment_status
        leo_appt.patient_id = patient.id
        leo_appt.provider_id = provider_sync_profile.provider_id
        leo_appt.appointment_type_id = appointment_type.id
        leo_appt.duration = athena_appt.duration.to_i

        leo_appt.start_datetime = AthenaHealthApiHelper.to_datetime(athena_appt.date, athena_appt.starttime)
        leo_appt.athena_id = athena_appt.appointmentid.to_i

        #attempt to find rescheduled appt.  If not found, it will get updated on the next run.
        if (athena_appt.respond_to? :rescheduledappointmentid) && (athena_appt.rescheduledappointmentid.to_i != 0)
          rescheduled_appt = Appointment.find_by(athena_id: athena_appt.rescheduledappointmentid.to_i)
          leo_appt.rescheduled_id = rescheduled_appt.id if rescheduled_appt
        end
      end

      leo_appt.sync_updated_at = DateTime.now.utc
      leo_appt.save!
    end

    def process_provider_leave(task)
      provider_sync_profile = ProviderSyncProfile.find_by!(provider_id: task.sync_id)
      blocked_appointment_type = AppointmentType.find_by!(name: "Block")

      blocked_appts = @connector.get_open_appointments(
        departmentid: provider_sync_profile.athena_department_id,
        appointmenttypeid: blocked_appointment_type.athena_id,
        providerid: provider_sync_profile.athena_id
      ).select {|appt| (appt.appointmenttypeid.to_i == blocked_appointment_type.athena_id && appt.providerid.to_i == provider_sync_profile.athena_id) }

      #delete all existing provider leaves that are synched from athena
      ProviderLeave.where(athena_provider_id: provider_sync_profile.athena_id).where.not(athena_id: 0).destroy_all

      #add new entries
      blocked_appts.each { |appt|
        start_datetime = AthenaHealthApiHelper.to_datetime(appt.date, appt.starttime)

        ProviderLeave.create(
          athena_id: appt.appointmentid.to_i, 
          athena_provider_id: appt.providerid.to_i, 
          description: "Synced from Athena block.id=#{appt.appointmentid}",
          start_datetime: start_datetime,
          end_datetime: start_datetime + appt.duration.to_i.minutes
        )
      }

      provider_sync_profile.leave_updated_at = DateTime.now.utc
      provider_sync_profile.save!
    end

    def find_preexisting_athena_patients()
      preexisting_patients = []

      Practice.find_each { |practice|
        preexisting_patients = preexisting_patients.concat(@connector.get_patients(departmentid: practice.athena_id))
      }

      puts "preexisting_patients: #{preexisting_patients}"
      preexisting_patients = preexisting_patients.select { |patient| !Patient.exists?(athena_id: patient[:patientid.to_s].to_i) }

      return preexisting_patients.map { |patient| patient[:patientid.to_s].to_i }.sort
    end

    def migrate_preexisting_athena_patient(athena_id, family_id)
      leo_patient = Patient.find_by(athena_id: athena_id)
      raise "Patient athena_id=#{athena_id} already exists in Leo" if leo_patient

      athena_patient = @connector.get_patient(patientid: athena_id)
      raise "No Athena patient found for athena_id=#{athena_id}" unless athena_patient

      family = Family.find(family_id)

      #create patient
      leo_patient = family.patients.new(
        first_name: athena_patient.firstname,
        last_name: athena_patient.lastname,
        birth_date: Date.strptime(athena_patient.dob, "%m/%d/%Y"),
        sex: athena_patient.sex,
        athena_id: athena_id)

      leo_patient.save!

      return leo_patient
    end

    def get_best_match_patient(leo_patient)
      leo_parent = leo_patient.family.primary_guardian
      patient_birth_date = leo_patient.birth_date.strftime("%m/%d/%Y") if leo_patient.birth_date

      athena_patient = nil

      begin
        #search by phone first
        athena_patient = @connector.get_best_match_patient(
          firstname: leo_patient.first_name, 
          lastname: leo_patient.last_name, 
          dob: patient_birth_date,
          anyphone: leo_parent.phone.gsub(/[^\d,\.]/, '')) if leo_parent.phone
      rescue => e
        SyncService.configuration.logger.info "bestmatch lookup by phone failed"
      end

      begin
        #search by email
        athena_patient = @connector.get_best_match_patient(
          firstname: leo_patient.first_name, 
          lastname: leo_patient.last_name, 
          dob: patient_birth_date,
          guarantoremail: leo_parent.email) unless athena_patient
      rescue => e
        SyncService.configuration.logger.info "bestmatch lookup by email failed"
      end

      athena_patient
    end

    #sync patient
    #SyncTask.sync_id = User.id
    #creates an instance of HealthRecord model if one does not exist, and then updates the patient in Athena
    def process_patient(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient.id #{leo_patient.id} has no associated family" unless leo_patient.family
      raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian

      SyncService.configuration.logger.info("Syncer: synching patient=#{leo_patient.to_json}")

      leo_parent = leo_patient.family.primary_guardian
      raise "patient.id #{leo_patient.id} has a primary guardian that is not associated with a practice" unless leo_parent.practice

      patient_birth_date = leo_patient.birth_date.strftime("%m/%d/%Y") if leo_patient.birth_date
      parent_birth_date = leo_parent.birth_date.strftime("%m/%d/%Y") if leo_parent.birth_date

      leo_guardians = leo_patient.family.guardians.order('created_at ASC')

      contactname = nil
      contactrelationship = nil
      contactmobilephone = nil

      if leo_guardians.size >= 2
        contactname = "#{leo_guardians[1].first_name} #{leo_guardians[1].last_name}"
        contactrelationship = "GUARDIAN"
        contactmobilephone = leo_guardians[1].phone
      end

      if leo_patient.athena_id == 0
        #look existing athena patient with same info
        athena_patient = get_best_match_patient(leo_patient)

        if athena_patient
          raise "patient.id #{leo_patient.id} has a best match in Athena (athena_id: #{athena_patient.patientid}), but that match is already connected to another patient" unless Patient.where(athena_id: athena_patient.patientid.to_i).empty?
        
          SyncService.configuration.logger.info("Syncer: connecting patient.id=#{leo_patient.id} to athena patient.id=#{athena_patient.patientid}")

          #use existing patient
          leo_patient.athena_id = athena_patient.patientid.to_i
          leo_patient.save!
        else          
          SyncService.configuration.logger.info("Syncer: creating new Athena patient for leo patient.id=#{leo_patient.id}")

          #create new patient
          leo_patient.athena_id = @connector.create_patient(
            departmentid: leo_parent.practice.athena_id,
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
            guarantorrelationshiptopatient: 3, #3==child
            contactname: contactname,
            contactrelationship: contactrelationship,
            contactmobilephone: contactmobilephone
            ).to_i

          leo_patient.save!
        end
      else
        #update patient
        @connector.update_patient(
          patientid: leo_patient.athena_id,
          departmentid: leo_parent.practice.athena_id,
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
          guarantorrelationshiptopatient: 3, #3==child
          contactname: contactname,
          contactrelationship: contactrelationship,
          contactmobilephone: contactmobilephone
          )
      end

      #create insurance if not entered yet
      insurances = @connector.get_patient_insurances(patientid: leo_patient.athena_id)
      primary_insurance = insurances.find { |ins| ins[:sequencenumber.to_s].to_i == 1 }

      insurance_plan = leo_parent.insurance_plan unless primary_insurance

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
      SyncService.configuration.logger.info("Syncer: synching photos=#{photos.to_json}")

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
      raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian

      leo_parent = leo_patient.family.primary_guardian

      #get list of allergies for this patients
      allergies = @connector.get_patient_allergies(patientid: leo_patient.athena_id, departmentid: leo_parent.practice.athena_id)

      #remove existing allergies for the user
      Allergy.destroy_all(patient_id: leo_patient.id)

      #create and/or update the allergy records in Leo
      allergies.each do | allergy |
        leo_allergy = Allergy.find_or_create_by(patient_id: leo_patient.id, athena_id: allergy[:allergenid.to_s].to_i)

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

    def process_patient_medications(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_patient.athena_id == 0
      raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian

      leo_parent = leo_patient.family.primary_guardian

      #get list of medications for this patients
      meds = @connector.get_patient_medications(patientid: leo_patient.athena_id, departmentid: leo_parent.practice.athena_id)

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
          leo_med.started_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'START'.to_sym)
          leo_med.ended_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'END'.to_sym)
          leo_med.ordered_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'ORDER'.to_sym)
          leo_med.filled_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'FILL'.to_sym)
          leo_med.entered_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'ENTER'.to_sym)
          leo_med.hidden_at = Date.strptime(evt[:eventdate.to_s], "%m/%d/%Y") if (evt[:type.to_s].to_sym == 'HIDE'.to_sym)
        end

        leo_med.save!
      end

      leo_patient.medications_updated_at = DateTime.now.utc
      leo_patient.save!
    end

    def process_patient_vitals(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_patient.athena_id == 0
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

          leo_vital = Vital.find_or_create_by(athena_id: reading[:vitalid.to_s].to_i)

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

    def process_patient_vaccines(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_patient.athena_id == 0
      raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian

      leo_parent = leo_patient.family.primary_guardian

      #get list of vaccines for this patients
      vaccs = @connector.get_patient_vaccines(patientid: leo_patient.athena_id, departmentid: leo_parent.practice.athena_id)

      #remove existing vaccines for the user
      Vaccine.destroy_all(patient_id: leo_patient.id)

      #create and/or update the vaccine records in Leo
      vaccs.each do | vacc |
        if vacc[:status.to_s] == 'ADMINISTERED'
          leo_vacc = Vaccine.find_or_create_by(athena_id: vacc[:vaccineid.to_s])

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

    def process_patient_insurances(task)
      leo_patient = Patient.find(task.sync_id)

      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_patient.athena_id == 0
      raise "patient.id #{leo_patient.id} has no primary_guardian in his family" unless leo_patient.family.primary_guardian

      leo_parent = leo_patient.family.primary_guardian

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
