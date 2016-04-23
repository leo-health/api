class AthenaProviderSyncService < AthenaSyncService
  def sync_provider_leave(provider_sync_profile)
    unavailable_appts_for_provider = @connector.get_open_appointments(
      departmentid: provider_sync_profile.athena_department_id,
      appointmenttypeid: 0,
      providerid: provider_sync_profile.athena_id,
      showfrozenslots: true,
      startdate: Date.today.strftime("%m/%d/%Y"),
      enddate: (Date.today + 6.months).strftime("%m/%d/%Y")
    ).select { |appt| (appt.try(:frozen) == "true" && appt.providerid.to_i == provider_sync_profile.athena_id) }

    ProviderLeave.where(athena_provider_id: provider_sync_profile.athena_id).where.not(athena_id: 0).destroy_all
    provider_sync_profile.update(leave_updated_at: DateTime.now.utc) if unavailable_appts_for_provider.size
    unavailable_appts_for_provider.map { |appt|
      start_datetime = AthenaHealthApiHelper.to_datetime(appt.date, appt.starttime)
      ProviderLeave.create(
        athena_id: appt.appointmentid.to_i,
        athena_provider_id: appt.providerid.to_i,
        description: "Synced from Athena block.id=#{appt.appointmentid}",
        start_datetime: start_datetime,
        end_datetime: start_datetime + appt.duration.to_i.minutes
      )
    }
  end
end
