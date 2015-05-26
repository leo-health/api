require "athena_health_api_helper"

module SyncService
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :sync_job_auto_reschedule
    attr_accessor :sync_job_delay

    def initialize
      @sync_job_auto_reschedule = true
      @sync_job_delay = 1.minutes
    end
  end
end

module SyncServiceHelper
  class Syncher
    @debug = false

    attr_reader :connector

    def initialize(connector)
      @connector = connector
    end

    # Process all sync tasks
    # Tasks that are completed will be removed from the table.  Tasks that failed
    # will stay.
    def process_all_sync_tasks()
      Rails.logger.info "Syncher: #{SyncTask.count} sync tasks detected"

      SyncTask.find_each() do |task|
        begin
          process_sync_task(task)

          #destroy task if everything went ok
          task.destroy
        rescue => e 
          Rails.logger.error "Syncher: Processing sync task id=#{task.id} failed"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end

    # process a single sync task.  An exception will be thrown if anything goes wrong.
    #
    # ==== arguments
    # * +task+ - the sync task to process
    def process_sync_task(task)
      Rails.logger.info("Processing task: #{task.to_json}")

      if task.sync_type.to_sym == :appointment
        process_appointment_task(task)
      elsif task.sync_type.to_sym == :gen_initial_appointment_tasks
        process_gen_initial_appointment_tasks_task(task)

      elsif task.sync_type.to_sym == :patient
        process_patient_task(task)
      elsif task.sync_type.to_sym == :patient_photo
        process_patient_photo_task(task)
      elsif task.sync_type.to_sym == :patient_allergies
        process_patient_allergies_task(task)
      elsif task.sync_type.to_sym == :patient_medications
        process_patient_medications_task(task)
      elsif task.sync_type.to_sym == :patient_vaccines
        process_patient_vaccines_task(task)
      elsif task.sync_type.to_sym == :patient_vitals
        process_patient_vitals_task(task)
      elsif task.sync_type.to_sym == :patient_insurance
        process_patient_insurance_task(task)
      else
        raise "Unknown task.sync_type entry: #{task.sync_type}"
      end
    end

    # Go through all existing appointments and add all missing sync tasks for appointments.
    #
    # ==== arguments
    # * +task+ - the sync task to process
    def process_gen_initial_appointment_tasks_task(task)
      raise "#{task.sync_type} task is not implemented with source set to #{task.sync_source}" unless task.leo?

      Appointment.find_each() do |appt|
        begin
          SyncTask.find_or_create_by(sync_id: appt.id, 
            sync_type: :appointment, 
            sync_source: :leo)
        rescue => e 
          Rails.logger.error "Syncher: Creating sync task for appointment.id=#{appt.id} failed"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end

    def sync_appt_to_athena(leo_appt, athena_appt)
      raise "Null input parameters" unless leo_appt && athena_appt

      #set frozen field
      @connector.freeze_appointment(appointmentid:leo_appt.athena_id, freeze: leo_appt.frozenyn)

      #return if nothing to be done
      return if (leo_appt.appointment_status == athena_appt.appointmentstatus)

      if athena_appt.open?
        #book
        Rails.logger.info("Syncher: Booking athena appointment: #{leo_appt.athena_patient_id}")
        @connector.book_appointment(
            appointmentid: leo_appt.athena_id,
            patientid: leo_appt.athena_patient_id,
            reasonid: nil,
            appointmenttypeid: leo_appt.athena_appointment_type_id,
            departmentid: leo_appt.athena_department_id
        )
      elsif athena_appt.future?
        raise "Cannot transition a booked appointment to open" if leo_appt.open?

        if leo_appt.cancelled?
          if leo_appt.rescheduled_appointment_id
            leo_resched_appt = Appointment.find(leo_appt.rescheduled_appointment_id)
            raise "Could not find rescheduled leo appt id: #{leo_appt.rescheduled_appointment_id}" if leo_resched_appt.nil?

            #sync rescheduled appointment first
            if leo_resched_appt.athena_id == 0
              sync_appt(leo_resched_appt) 
              leo_resched_appt = Appointment.find(leo_appt.rescheduled_appointment_id)
            end

            Rails.logger.info("Syncher: Rescheduling athena appointment: #{leo_appt.athena_id}")
            @connector.reschedule_appointment(
              appointmentid: leo_appt.athena_id,
              newappointmentid: leo_resched_appt.athena_id, 
              patientid: leo_appt.athena_patient_id
            )
          else
            #cancel
            Rails.logger.info("Syncher: Cancelling athena appointment: #{leo_appt.athena_id}")
            @connector.cancel_appointment(appointmentid: leo_appt.athena_id, patientid: leo_appt.athena_patient_id) if athena_appt.booked?
          end
        else
          raise "Cannot transition athena appt id=#{athena_appt.appointmentid} to #{leo_appt.appointment_status} status"
        end
      else
        raise "Cannot transition athena appt id=#{athena_appt.appointmentid} to #{leo_appt.appointment_status} status"
      end

      #recursively call the function until the appointment is as synched as it can be
      athena_appt = @connector.get_appointment(appointmentid: leo_appt.athena_id)
      sync_appt_to_athena(leo_appt, athena_appt)
    end

    def sync_appt_from_athena(leo_appt, athena_appt)
      raise "Null input parameters" unless leo_appt && athena_appt

      if leo_appt.appointment_status != athena_appt.appointmentstatus
        leo_appt.appointment_status = athena_appt.appointmentstatus

        leo_appt.athena_appointment_type = athena_appt.appointmenttype
        #todo: do we need to update leo_appointment_type
        leo_appt.athena_provider_id = athena_appt.providerid.to_i
        #todo: do we need to update leo_provider_id
        leo_appt.athena_department_id = athena_appt.departmentid.to_i
        leo_appt.athena_appointment_type_id = athena_appt.appointmenttypeid.to_i
        leo_appt.athena_patient_id = athena_appt.patientid.to_i
        #todo: do we need to update leo_patient_id


        #todo: any other stuff that would need to get synched back to leo
        #the following should not change from athena side
        #rescheduled_appointment_id = athena_appt.rescheduledappointmentid
        #duration = athena_appt.duration
        #appointment_date = 
        #appointment_start_time = 
        #frozenyn = athena_appt.frozenyn

        leo_appt.skip_sync_callbacks = true
        leo_appt.save!
        leo_appt.skip_sync_callbacks = false
      end
    end

    def sync_appt(leo_appt)
      #create appointment if missing
      if leo_appt.athena_id == 0
        if leo_appt.post_checked_in?
          raise "Encountered an appointment id=#{leo_appt.id} in a state that that cannot be reproduced in athena"
        end

        leo_appt.athena_id = @connector.create_appointment(
          appointmentdate: leo_appt.appointment_date.strftime("%m/%d/%Y"),
          appointmenttime: leo_appt.appointment_start_time.strftime("%H:%M"), 
          appointmenttypeid: leo_appt.athena_appointment_type_id,
          departmentid: leo_appt.athena_department_id,
          providerid: leo_appt.athena_provider_id
        )
        leo_appt.skip_sync_callbacks = true
        leo_appt.save!
        leo_appt.skip_sync_callbacks = false
      end

      athena_appt = @connector.get_appointment(appointmentid: leo_appt.athena_id)
      raise "Could not find athena appointment with id=#{leo_appt.athena_id}" if athena_appt.nil?

      if athena_appt.pre_checked_in?
        #sync from leo to athena
        sync_appt_to_athena(leo_appt, athena_appt)
      else
        #sync from athena to leo
        sync_appt_from_athena(leo_appt, athena_appt)
      end
    end

    # sync leo and athena appointment.  
    # An exception will be thrown if anything goes wrong.
    #
    # ==== arguments
    # * +task+ - the sync task to process  
    def process_appointment_task(task)
      if task.leo?
        leo_appt = Appointment.find(task.sync_id)
        return if leo_appt.nil?

        sync_appt(leo_appt)
      elsif task.athena?
        athena_appt = @connector.get_appointment(appointmentid: task.sync_id)
        return if athena_appt.nil?

        leo_appts = Appointment.find(:all, athena_id: task.sync_id)

        if leo_appts.empty?
          #disabled deleting open appointments for now
          if false
            #delete an appointment that does not exist in leo
            raise "only open athena appts can be deleted" unless athena_appt.open?
            Rails.logger.info("Deleting athena appointment because it does not exist in Leo: #{task.sync_id}")
            @connector.delete_appointment(appointmentid: task.sync_id)
          end
        else
          #if record exists, run sync task for those leo records
          leo_appts.each do |leo_appt|
            process_appointment_task(SyncTask.new(
              sync_source: :leo, 
              sync_type: :appointment,
              sync_id: leo_appt.id))
          end
        end
      else
        raise "#{task.sync_type} task is not implemented with source set to #{task.sync_source}"
      end
    end

    #sync patient
    #SyncTask.sync_id = User.id
    #creates an instance of Patient model if one does not exist, and then updates the patient in Athena
    def process_patient_task(task)
      raise "patient task cannot be called with sync_source set to athena: #{task.to_json}" if task.athena?

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
          Rails.logger.error "Syncher: Creating patient for user.id=#{task.sync_id} failed"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end

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
            guarantorrelationshiptopatient: 2
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
            guarantorrelationshiptopatient: 2
            )
        end
      end
    end

    #sync patient
    #SyncTask.sync_id = User.id
    def process_patient_photo_task(task)
      raise "patient photo task cannot be called with sync_source set to athena: #{task.to_json}" if task.athena?

      leo_user = User.find(task.sync_id)

      raise "missing patient associated with user.id=#{task.sync_id}" if leo_user.patient.nil?
      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_user.patient.athena_id == 0

      #get list of photos for this patients
      photos = leo_user.patient.photos.order("id desc")

      if photos.empty?
        @connector.delete_patient_photo(patientid: leo_user.patient.athena_id)
      else
        @connector.set_patient_photo(patientid: leo_user.patient.athena_id, image: photos.first.image)
      end
    end

    def process_patient_allergies_task(task)
      raise "not implemented"
    end

    def process_patient_medications_task(task)
      raise "patient medicatins task cannot be called with sync_source set to leo: #{task.to_json}" if task.leo?

      leo_user = User.find(task.sync_id)

      raise "missing patient associated with user.id=#{task.sync_id}" if leo_user.patient.nil?
      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_user.patient.athena_id == 0

      #get list of medications for this patients
      meds = @connector.get_patient_medications(patientid: leo_user.patient.athena_id, departmentid: leo_user.practice_id)

      #create and/or update the medication records in Leo
      meds.each do | med |
        leo_med = Medication.find_or_create_by(athena_id: med.medicationid)

        leo_med.patient_id = leo_user.patient_id
        leo_med.athena_id = med.medicationid.to_i
        leo_med.medication = med.medication.to_s
        leo_med.sig = med.unstructuredsig.to_s
        leo_med.patient_note = med.patientnote.to_s
        leo_med.started_at = nil
        leo_med.ended_at = nil
        leo_med.ordered_at = nil
        leo_med.filled_at = nil
        leo_med.entered_at = nil
        leo_med.hidden_at = nil

        med.events.each do | evt |
          leo_med.started_at = DateTime.strptime(evt.eventdate, "%m/%d/%Y") if (evt.type.to_sym == 'START'.to_sym)
          leo_med.ended_at = DateTime.strptime(evt.eventdate, "%m/%d/%Y") if (evt.type.to_sym == 'END'.to_sym)
          leo_med.ordered_at = DateTime.strptime(evt.eventdate, "%m/%d/%Y") if (evt.type.to_sym == 'ORDER'.to_sym)
          leo_med.filled_at = DateTime.strptime(evt.eventdate, "%m/%d/%Y") if (evt.type.to_sym == 'FILL'.to_sym)
          leo_med.entered_at = DateTime.strptime(evt.eventdate, "%m/%d/%Y") if (evt.type.to_sym == 'ENTER'.to_sym)
          leo_med.hidden_at = DateTime.strptime(evt.eventdate, "%m/%d/%Y") if (evt.type.to_sym == 'HIDE'.to_sym)
        end

        leo_med.save!
      end
    end

    def process_patient_vitals_task(task)
      raise "not implemented"
    end

    def process_patient_vaccines_task(task)
      raise "patient vaccines task cannot be called with sync_source set to leo: #{task.to_json}" if task.leo?

      leo_user = User.find(task.sync_id)

      raise "missing patient associated with user.id=#{task.sync_id}" if leo_user.patient.nil?
      raise "patient for user.id=#{task.sync_id} has not been synched with athena yet" if leo_user.patient.athena_id == 0

      #get list of vaccines for this patients
      vaccs = @connector.get_patient_vaccines(patientid: leo_user.patient.athena_id, departmentid: leo_user.practice_id)

      #create and/or update the vaccine records in Leo
      vaccs.each do | vacc |
        leo_vacc = Vaccine.find_or_create_by(athena_id: vacc.vaccineid)

        leo_vacc.patient_id = leo_user.patient_id
        leo_vacc.athena_id = vacc.vaccineid.to_i
        leo_vacc.vaccine = vacc.description.to_s
        leo_vacc.administered_at = DateTime.strptime(vacc.administerdate, "%m/%d/%Y") if vacc.administerdate

        leo_vacc.save!
      end
    end

    def process_patient_insurance_task(task)
      raise "not implemented"
    end
  end
end

