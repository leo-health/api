require "athena_health_api_helper"

module SyncServiceHelper
  class Syncher
    @debug = false

    attr_reader :api_helper

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
          Rails.logger.error "Processing sync task id=#{task.id} failed"
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
      case task.sync_type
      when :appointment
        process_appointment_task(task)
      when :gen_initial_appointment_tasks
        process_gen_initial_appointment_tasks_task(task)
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
          Rails.logger.error "Creating sync task for appointment.id=#{appt.id} failed"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end

    # Synchronize the status of leo appointment with athena one
    # An exception will be thrown if anything goes wrong.
    def sync_athena_appt_status(leo_appt)
        athena_appt = @connector.get_appointment(appointmentid: leo_appt.athena_id)
        raise "Could not find athena appointment with id=#{leo_appt.athena_id}" if athena_appt.nil?

        #return if nothing to be done
        return if (leo_appt.appointment_status == athena_appt.appointmentstatus)

        if athena_appt.open?
          #book
          @connector.book_appointment(
              appointmentid: leo_appt.athena_id,
              patientid: leo_appt.athena_patient_id,
              reasonid: nil
          )
        elsif athena_appt.future?
          raise "Cannot transition a booked appointment to open" if leo_appt.open?

          if leo_appt.cancelled?
            #cancel
            @connector.cancel_appointment(appointmentid: leo_appt.athena_id) if athena_appt.booked?
          else
            #check in
            @connector.checkin_appointment(
                appointmentid: leo_appt.athena_id,
            )
          end
        elsif athena_appt.checked_in?
          Rails.logger.warn("Cannot transition appt out of \"checked in\" state using AthenaAPI")
          return
        elsif athena_appt.checked_out?
          Rails.logger.warn("Cannot transition appt out of \"checked out\" state using AthenaAPI")
          return
        elsif athena_appt.charge_entered?
          Rails.logger.warn("Cannot transition appt out of \"charge entered\" state using AthenaAPI")
          return
        else
          raise "unknown appointment status on athena_appt #{athena_appt.to_json}"
        end

        #recursively call the function until the appointment is fully synched
        sync_athena_appt_status(leo_appt)
    end

    # sync leo and athena appointment.  
    # An exception will be thrown if anything goes wrong.
    #
    # ==== arguments
    # * +task+ - the sync task to process  
    def process_appointment_task(task)
      if task.leo?
        #sync from leo to athena
        leo_appt = Appointment.find(task.sync_id)
        return if leo_appt.nil?

        #create appointment if missing
        if leo_appt.athena_id == 0
          leo_appt.athena_id = @connector.create_appointment(
            appointmentdate: leo_appt.appointment_date, #todo 
            appointmenttime: leo_appt.appointment_start_time, #todo 
            appointmenttypeid: leo_appt.athena_appointment_type_id, #todo: do we need to look this up?
            departmentid: leo_appt.athena_department_id, #todo: missing
            providerid: leo_appt.athena_provider_id, #todo: do we need to look it up
            reasonid: nil #todo: unused
          )
          leo_appt.save!
        end

        #set frozen field
        @connector.freeze_appointment(appointmentid:leo_appt.athena_id, freeze: leo_appt.frozenyn)

        #sync appointment status
        sync_athena_appt_status(leo_appt)

      elsif task.athena?
        
        #sync from athena to leo
        athena_appt = @connector.get_appointment(appointmentid: task.sync_id)
        return if athena_appt.nil?

        leo_appts = Appointment.find(:all, athena_id: task.sync_id)

        if leo_appts.empty?
          raise "only open athena appts can be deleted to synch with leo" unless athena_appt.open?
          @connector.delete_appointment(appointmentid: task.sync_id)
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
  end
end
