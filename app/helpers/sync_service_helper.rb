require "athena_health_api_helper"

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
      SyncTask.find_each() do |task|
        begin
          process_sync_task(task)

          #destroy task if everything went ok
          task.destroy
        rescue => e 
          Rails.logger.error "SyncServiceHelper: Processing sync task id=#{task.id} failed"
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
          Rails.logger.error "SyncServiceHelper: Creating sync task for appointment.id=#{appt.id} failed"
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
        Rails.logger.info("SyncServiceHelper: Booking athena appointment: #{leo_appt.athena_patient_id}")
        @connector.book_appointment(
            appointmentid: leo_appt.athena_id,
            patientid: leo_appt.athena_patient_id,
            reasonid: nil
        )
      elsif athena_appt.future?
        raise "Cannot transition a booked appointment to open" if leo_appt.open?

        if leo_appt.cancelled?
          if leo_appt.rescheduled_appointment_id.nil?
            leo_resched_appt = Appointment.find(leo_appt.rescheduled_appointment_id)
            raise "Could not find rescheduled leo appt id: #{leo_appt.rescheduled_appointment_id}" if leo_resched_appt.nil?
            raise "Rescheduled appointment #{leo_appt.rescheduled_appointment_id} has not been synched with Athena yet.  This should be cleared up on the next run." if leo_resched_appt.athena_id == 0

            Rails.logger.info("SyncServiceHelper: Rescheduling athena appointment: #{leo_appt.athena_id}")
            @connector.reschedule_appointment(
              appointmentid: leo_appt.athena_id,
              newappointmentid: leo_resched_appt.athena_id, 
              patientid: leo_appt.athena_patient_id
            )
          else
            #cancel
            Rails.logger.info("SyncServiceHelper: Cancelling athena appointment: #{leo_appt.athena_id}")
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

      leo_appt.appointment_status = athena_appt.appointmentstatus
      leo_appt.
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
          leo_appt.save!
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

    # Synchronize the status of leo appointment with athena one
    # An exception will be thrown if anything goes wrong.
    def sync_athena_appt_status(leo_appt)
        athena_appt = @connector.get_appointment(appointmentid: leo_appt.athena_id)
        raise "Could not find athena appointment with id=#{leo_appt.athena_id}" if athena_appt.nil?

    end

    # sync leo and athena appointment.  
    # An exception will be thrown if anything goes wrong.
    #
    # ==== arguments
    # * +task+ - the sync task to process  
    def process_appointment_task(task)
      if task.leo?
        #sync based on leo id
        leo_appt = Appointment.find(task.sync_id)
        return if leo_appt.nil?

        #create appointment if missing
        if leo_appt.athena_id == 0
          leo_appt.athena_id = @connector.create_appointment(
            appointmentdate: leo_appt.appointment_date.strftime("%m/%d/%Y"),
            appointmenttime: leo_appt.appointment_start_time.strftime("%H:%M"), 
            appointmenttypeid: leo_appt.athena_appointment_type_id,
            departmentid: leo_appt.athena_department_id,
            providerid: leo_appt.athena_provider_id
          )
          leo_appt.save!
        end

        #set frozen field
        @connector.freeze_appointment(appointmentid:leo_appt.athena_id, freeze: leo_appt.frozenyn)

        #sync appointment status
        sync_athena_appt_status(leo_appt)

      elsif task.athena?
        
        #sync based on athena id
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
  end
end
