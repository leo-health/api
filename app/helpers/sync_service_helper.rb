require "athena_health_api_helper"

module SyncServiceHelper
  @debug = true

  # process all sync tasks
  # Tasks that are completed will be removed from the table.  Tasks that failed
  # will stay.
  def self.process_all_sync_tasks()
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
  def self.process_sync_task(task: )
    case task.type
    when :appointment
      process_appointment_task(task: task)
    when :gen_initial_appointment_tasks
      process_gen_initial_appointment_tasks(task: task)
    else
      raise "Unknown task.table entry: #{task.table}"
    end
  end

  # Go through all existing appointments and add all missing sync tasks for appointments.
  #
  # ==== arguments
  # * +task+ - the sync task to process
  def self.process_gen_initial_appointment_tasks(task: )
    raise "#{task.type} task is not implemented with source set to #{task.source}" unless task.source == :leo

    Appointment.find_each() do |appt|
      begin
        SyncTask.find_or_create_by(leo_id: task.sync_id, type: :appointment, source: :leo)
      rescue => e 
        Rails.logger.error "Creating sync task for appointment.id=#{appt.id} failed"
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
      end
    end
  end

  #delete athena appointment
  # cancel if booked, delete open if exists
  def self.delete_athena_appointment(athena_appt: )
    if !athena_appt.nil?
      #cancel athena_appt if booked
      if athena_appt.booked?
        AthenaHealthApiHelper.cancel_booked_appointment(appointmentid: leo_appt.athena_id)
      end

      #delete appointment
      AthenaHealthApiHelper.delete_open_appointment(appointmentid: leo_appt.athena_id)
    end
  end

  # sync leo and athena appointment.  An exception will be thrown if anything goes wrong.
  #
  # ==== arguments
  # * +task+ - the sync task to process  
  def self.process_appointment_task(task: )
    if task.source == :leo
      #sync from leo to athena
      leo_appt = Appointment.find(task.sync_id)
      athena_appt = AthenaHealthApiHelper.get_appointment(appointmentid: leo_appt.athena_id)

      if leo_appt.cancelled
        if leo_appt.athena_id != 0
          raise "Expected athena_appt to exist at this point.  Leo appt.id=#{leo_appt.id} has an invalid athena_id=#{leo_appt.athena_id}" if athena_appt.nil?

          delete_athena_appointment(athena_appt)

          #save changes to leo appt
          leo_appt.athena_id = 0
          leo_appt.save!
        end
      else
        if task.athena_id == 0
          #create open appointment
          athena_appt_id = AthenaHealthApiHelper.create_open_appointment(todo)

          #save changes to leo appt
          leo_appt.athena_id = athena_appt_id
          leo_appt.save!

          #get the appointment for booking
          athena_appt = AthenaHealthApiHelper.get_appointment(appointmentid: leo_appt.athena_id)
        end

        raise "Expected athena_appt to exist at this point.  Leo appt.id=#{leo_appt.id} has an invalid athena_id=#{leo_appt.athena_id}" if athena_appt.nil?

        if !athena_appt.booked?
          AthenaHealthApiHelper.book_open_appointment(appointmentid: leo_appt.athena_id)
        end
      end
    elsif task.source == :athena
      #sync from athena to leo
      athena_appt = AthenaHealthApiHelper.get_appointment(appointmentid: task.sync_id)

      #delete athena appt if there is no reference to it in leo
      delete_athena_appointment(athena_appt) if !athena_appt.nil? && !Appointment.exists?(cancelled: false, athena_id: task.sync_id)
    else
      raise "#{task.type} task is not implemented with source set to #{task.source}"
    end
  end
end
