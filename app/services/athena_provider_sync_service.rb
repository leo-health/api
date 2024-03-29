class AthenaProviderSyncService < AthenaSyncService
  def sync_open_slots(provider, start_date = nil, end_date = nil)

    query_start = (start_date || Date.today).beginning_of_day
    query_end = (end_date || (query_start + 6.months)).end_of_day
    format_date = Proc.new { |d| d.strftime("%m/%d/%Y") }

    # TODO: Make Generic to handle any Syncable type

    # Clean any unusable slots
    Slot.start_date_time_between(nil, Time.now).destroy_all

    # Get athena resources and leo resources
    athena_res = @connector.get_open_appointments(
      departmentid: provider.athena_department_id,
      appointmenttypeid: 0,
      providerid: provider.athena_id,
      showfrozenslots: true,
      startdate: format_date.call(query_start),
      enddate: format_date.call(query_end)
    )

    leo_res = Slot.where(provider: provider).start_date_time_between(query_start, query_end)
    # Map key = athena_id, value = [athena_res, leo_res]
    athena_map = Hash[athena_res.map {|r| [r.appointmentid.to_i, [r, nil]] }]
    leo_map = Hash[leo_res.map {|r| [r.athena_id, [nil, r]]}]

    # Merge the hashes to associate the athena_res with the leo_res
    merged_map = athena_map.merge(leo_map) { |athena_id, athena_r, leo_r| [athena_r[0], leo_r[1]] }

    # Create or update in leo
    merged_map.values.map { |merged_r| create_or_update_slot(*merged_r, provider) }
  end

  def create_or_update_slot(athena_slot, leo_slot, provider)
    attributes = athena_slot ? parse_slot_json(athena_slot) : { free_busy_type: :busy }
    if leo_slot
      leo_slot.update attributes
    else
      leo_slot = Slot.create! attributes.reverse_merge({ provider: provider })
    end
    leo_slot
  end

  def parse_slot_json(slot)
    start_datetime = AthenaHealthApiHelper::to_datetime(slot.date, slot.starttime)
    {
      start_datetime: start_datetime,
      end_datetime: start_datetime + slot.duration.to_i.minutes,
      free_busy_type: slot.try(:frozen) == "true" ? :busy : :free,
      athena_id: slot.appointmentid.to_i,
    }
  end
end
