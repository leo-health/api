namespace :backfill do
  desc 'ensure unique sessions by device_token'
  task destroy_duplicate_slots: :environment do

    athena_ids_with_duplicates = Slot.group(:athena_id).count
    .select{|athena_id, n_dups| n_dups > 1}
    .keys

    duplicate_slots = Slot.where(athena_id: athena_ids_with_duplicates)
    .select([:id, :athena_id, :created_at])
    .order(:athena_id, :created_at)

    c = 0
    duplicate_slots
    .reduce({}) { |slots_to_keep, slot|

      # Delete all but the last created_at slot
      prev_slot = slots_to_keep[slot.athena_id]
      slot_to_keep = prev_slot || slot

      if slot.created_at > slot_to_keep.created_at
        Slot.destroy(prev_slot.id)
        c += 1
        puts "destroying duplicate for athena_id: #{prev_slot.athena_id}"
      else
        puts "keeping slot #{slot_to_keep.id} for athena_id: #{slot.athena_id}"
      end

      slots_to_keep[slot.athena_id] = slot_to_keep
      slots_to_keep
    }

    puts "finished destroying #{c} duplicate slots"
  end
end
