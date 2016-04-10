class AthenaProviderSyncService < AthenaSyncService
  def sync_provider_leave(provider_sync_profile)

    blocked_appointment_type = AppointmentType.find_by!(name: "Block")

    blocked_appts = @connector.get_open_appointments(
    departmentid: provider_sync_profile.athena_department_id,
    appointmenttypeid: blocked_appointment_type.athena_id,
    providerid: provider_sync_profile.athena_id
    ).select {|appt| (appt.appointmenttypeid.to_i == blocked_appointment_type.athena_id && appt.providerid.to_i == provider_sync_profile.athena_id) }

    frozen_appts = @connector.get_open_appointments(
    departmentid: provider_sync_profile.athena_department_id,
    appointmenttypeid: 0,
    providerid: provider_sync_profile.athena_id,
    showfrozenslots: true
    ).select {|appt| (appt.try(:frozen) == "true" && appt.providerid.to_i == provider_sync_profile.athena_id) }

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

    frozen_appts.each { |appt|
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
end
