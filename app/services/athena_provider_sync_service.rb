class AthenaProviderSyncService < AthenaSyncService
  def sync_open_slots(provider_sync_profile, start_date = nil, end_date = nil)

    query_start = start_date || Date.today
    query_end = end_date || (query_start + 1.year)
    format_date = Proc.new { |d| d.strftime("%m/%d/%Y") }

    # TODO: Make Generic

    # Get athena resources and leo resources
    athena_res = @connector.get_open_appointments(
      departmentid: provider_sync_profile.athena_department_id,
      appointmenttypeid: 0,
      providerid: provider_sync_profile.athena_id,
      showfrozenslots: true,
      startdate: format_date.call(query_start),
      enddate: format_date.call(query_end)
    )
    leo_res = Slot.where(provider_sync_profile_id: provider_sync_profile.id).where("start_datetime >= ? AND end_datetime <= ?", query_start, query_end)

    # Map key = athena_id, value = [athena_res, leo_res]
    athena_map = Hash[athena_res.map {|r| [r.appointmentid.to_i, [r, nil]] }]
    leo_map = Hash[leo_res.map {|r| [r.athena_id, [nil, r]]}]

    # Merge the hashes to associate the athena_res with the leo_res
    merged_map = athena_map.merge(leo_map) { |athena_id, athena_r, leo_r| [athena_r[0], leo_r[1]] }

    # Create or update in leo
    merged_map.values.map { |merged_r| create_or_update_slot(*merged_r, provider_sync_profile) }
  end

  def create_or_update_slot(athena_slot, leo_slot, provider_sync_profile)
    attributes = athena_slot ? parse_slot_json(athena_slot) : { free_busy_type: :busy }
    if leo_slot
      leo_slot.update attributes
    else
      leo_slot = Slot.create! attributes.reverse_merge({ provider_sync_profile: provider_sync_profile })
    end
    leo_slot
  end

  def parse_slot_json(slot)
    start_datetime = AthenaHealthApiHelper::to_datetime(slot.date, slot.starttime)
    {
      start_datetime: start_datetime,
      end_datetime: start_datetime + slot.duration.to_i.minutes,
      free_busy_type: slot.frozen == "true" ? :busy : :free,
      athena_id: slot.appointmentid.to_i,
    }
  end

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
