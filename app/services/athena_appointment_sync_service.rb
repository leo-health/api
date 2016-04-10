class AthenaAppointmentSyncService < AthenaSyncService
  def post_appointment(leo_appt)
    if leo_appt.athena_id == 0
      raise "Appointment appt.id=#{leo_appt.id} is in a state that cannot be reproduced in Athena" if leo_appt.open? || leo_appt.post_checked_in?
      if leo_appt.patient.athena_id == 0
        sync_leo_patient leo_appt.patient
        # raise "Appointment appt.id=#{leo_appt.id} is booked by a user that has not been synched yet"
      end
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

    #early exit if the appointment date is older then current time
    return if leo_appt.start_datetime < DateTime.now

    athena_appt = @connector.get_appointment(appointmentid: leo_appt.athena_id)
    raise "Could not find athena appointment with id=#{leo_appt.athena_id}" unless athena_appt

    if athena_appt.future? && leo_appt.cancelled?
      #cancel
      @connector.cancel_appointment(appointmentid: leo_appt.athena_id,
      patientid: athena_appt.patientid) if athena_appt.booked?
    else
      #update from athena
      patient = Patient.find_by(athena_id: athena_appt.patientid.to_i)
      provider_sync_profile = ProviderSyncProfile.find_by!(athena_id: athena_appt.providerid.to_i)
      appointment_type = AppointmentType.find_by!(athena_id: athena_appt.appointmenttypeid.to_i)
      appointment_status = AppointmentStatus.find_by(status: athena_appt.appointmentstatus)
      #athena does not return booked_by_id.  we have to leave it as is
      leo_appt.appointment_status = appointment_status
      leo_appt.patient_id = patient.try(:id)
      leo_appt.provider_id = provider_sync_profile.provider_id
      leo_appt.appointment_type_id = appointment_type.id
      leo_appt.duration = athena_appt.duration.to_i
      leo_appt.start_datetime = AthenaHealthApiHelper.to_datetime(athena_appt.date, athena_appt.starttime)
      leo_appt.athena_id = athena_appt.appointmentid.to_i
      #attempt to find rescheduled appt.  If not found, it will get updated on the next run.
      if (athena_appt.respond_to? :rescheduledappointmentid) && (athena_appt.rescheduledappointmentid.to_i != 0)
        rescheduled_appt = Appointment.find_by(athena_id: athena_appt.rescheduledappointmentid.to_i)
        unless rescheduled_appt
          #sync rescheduled appointment
          rescheduled_athena_appt = @connector.get_appointment(appointmentid: athena_appt.rescheduledappointmentid)
          rescheduled_appt = create_leo_appointment_from_athena(appt: rescheduled_athena_appt) if rescheduled_athena_appt
        end

        leo_appt.rescheduled_id = rescheduled_appt.id if rescheduled_appt
      end
    end

    leo_appt.sync_updated_at = DateTime.now.utc
    leo_appt.save!
  end

  def sync_appointments_for_family(family)
    family.patients.reduce([]) { |appointments, patient| appointments += sync_athena_appointments_for_patient patient }
  end

  def sync_appointments_for_practice(practice)
    sync_athena_appointments({
      departmentid: practice.athena_id,
    })
  end

  def sync_appointments_for_patient(patient)
    sync_athena_appointments({
      departmentid: patient.family.primary_guardian.practice.athena_id,
      patientid: patient.athena_id
    })
  end

  private

  def sync_appointments(athena_params)
    params = {
      startdate: Date.today.strftime("%m/%d/%Y"),
      enddate: 1.year.from_now.strftime("%m/%d/%Y")
    }.reverse_merge(athena_params)
    booked_appts = @connector.get_booked_appointments(**params)
    booked_appts.map { |appt|
      leo_appt = Appointment.find_by(athena_id: appt.appointmentid.to_i)

      if leo_appt
        if appt.cancelled?
          leo_appt.update appointment_status: AppointmentStatus.cancelled
        end

        if !leo_appt.patient
          # TODO: find a way to optimize this so we don't have to make this db call all the time
          # maybe we can add a patient_athena_id to Appointment, then on create patient we can associate all their existing appointments
          leo_patient = Patient.find_by(athena_id: appt.patientid.to_i)
          leo_appt.update(patient: leo_patient)
        end
      elsif appt.future?
        leo_appt = create_leo_appointment_from_athena appt
      end
      leo_appt
    }
  end

  def create_leo_appointment_from_athena!(appt)

    # TODO: refactor to end early based on validations to minimize db calls
    new_appt = nil
    patient = Patient.find_by(athena_id: appt.patientid.to_i)
    provider_sync_profile = ProviderSyncProfile.find_by(athena_id: appt.providerid.to_i)
    appointment_type = AppointmentType.find_by(athena_id: appt.appointmenttypeid.to_i)
    appointment_status = AppointmentStatus.find_by(status: appt.appointmentstatus)
    practice = Practice.find_by(athena_id: appt.departmentid)
    provider = provider_sync_profile.try(:provider)

    new_appt = Appointment.create!(
      appointment_status: appointment_status,
      booked_by: provider,
      patient: patient,
      provider: provider,
      practice: practice,
      appointment_type: appointment_type,
      duration: appt.duration,
      start_datetime: start_datetime,
      sync_updated_at: DateTime.now,
      athena_id: appt.appointmentid.to_i
    )
  end
end
