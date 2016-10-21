class AthenaProviderSyncService < AthenaSyncService
  def sync_open_slots(provider, start_date = nil, end_date = nil)

    beginning_of_today = (start_date || Date.today).beginning_of_day
    eod_six_months_from_now = (end_date || (beginning_of_today + 6.months)).end_of_day

    format_date = Proc.new { |d| d.strftime("%m/%d/%Y") }

    # Clean any unusable slots
    Slot.start_date_time_between(nil, Time.now).destroy_all

    # Get athena slots and leo slots
    athena_slots = @connector.get_open_appointments(
      departmentid: provider.athena_department_id,
      appointmenttypeid: 0,
      providerid: provider.athena_id,
      showfrozenslots: true,
      startdate: format_date.call(beginning_of_today),
      enddate: format_date.call(eod_six_months_from_now)
    ).select { |slot|
      slot.appointmenttypeid.try(:to_i) == AppointmentType::ANY_10_TYPE_ATHENA_ID
    }

    leo_slots = Slot.where(provider: provider).start_date_time_between(beginning_of_today, eod_six_months_from_now)

    athena_map = athena_slots.reduce({}) { |athena_id_map_to_athena_pair, slot|
      athena_id = slot.appointmentid.to_i
      athena_pair = {athena: slot, leo: nil}
      athena_id_map_to_athena_pair[athena_id] = athena_pair
      athena_id_map_to_athena_pair
    }

    leo_map = leo_slots.reduce({}) { |athena_id_map_to_leo_pair, slot|
      athena_id = slot.athena_id
      leo_pair = {athena: nil, leo: slot}
      athena_id_map_to_leo_pair[athena_id] = leo_pair
      athena_id_map_to_leo_pair
    }

    # Merge the hashes to associate the athena_res with the leo_res
    merged_map = athena_map.merge(leo_map) { |athena_id, athena_pair, leo_pair|
      merged_pair = {athena: athena_pair[:athena], leo: leo_pair[:leo]}
      merged_pair
    }

    # Create or update in leo
    merged_map.values.map { |merged_pair| create_or_update_slot(*merged_pair.values, provider) }
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
