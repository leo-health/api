module Leo
  module V1
    class AppointmentSlots < Grape::API
      resource :appointment_slots do
        desc "Return all open slots for a specified provider"
        before do
          authenticated
        end

        params do
          requires :start_date, type: String, desc: "Start date", allow_blank: false
          requires :end_date, type: String, desc: "End date", allow_blank: false
          requires :appointment_type_id, type: Integer, desc: "Appointment Type", allow_blank: false
          optional :provider_id, type: Integer, desc: "Get slots for a single provider", allow_blank: false
          optional :provider_ids, type: Array[Integer], desc: "Get slots for multiple providers", allow_blank: false
          optional :appointment_id, type: Integer, desc: "Existing appointment to reschedule", allow_blank: false
        end

        get do
          provider_ids = []
          provider_ids += params[:provider_ids] if params[:provider_ids]
          provider_ids += [params[:provider_id]] if params[:provider_id]
          provider_ids = Provider.ids if provider_ids.empty?
          provider_ids = provider_ids.uniq

          appointment_type = AppointmentType.find(params[:appointment_type_id])
          start_date = [Date.strptime(params[:start_date], "%m/%d/%Y"), Time.now + Appointment::MIN_INTERVAL_TO_SCHEDULE].max
          end_date = Date.strptime(params[:end_date], "%m/%d/%Y")

          provider_ids.map do |provider_id|
            slots_json = []
            if provider = Provider.find_by(id: provider_id)
              slots = Slot.free.where(provider: provider).start_datetime_between(start_date, end_date.end_of_day).order(:start_datetime)

              # Allow rescheduling for the same time if the current_user owns the appointment
              if existing_appointment = Appointment.find_by_id(params[:appointment_id])
                same_family_as_current_user = existing_appointment.patient.family_id == current_user.family_id
                same_provider = existing_appointment.provider_id == provider.id
                attempting_to_reschedule = same_family_as_current_user && same_provider
                if attempting_to_reschedule
                  slots += [existing_appointment]
                end
              end

              filtered_slots = filter_slots_based_on_duration(slots, appointment_type.duration.minutes)
              # HACK: filter out saturdays
              filtered_slots = filtered_slots.reject { |slot| slot.start_datetime.saturday? || slot.start_datetime.sunday? }
              slots_json = filtered_slots.map { |available_slot| {start_datetime: available_slot.start_datetime, duration: appointment_type.duration} }
            end
            { provider_id: provider_id, slots: slots_json }
          end
        end
      end

      helpers do
        def filter_slots_based_on_duration(slots, requested_duration)
          filtered_slots = []
          i = 0
          while i < slots.size
            slot_available = false
            slot_unavailabile = false
            total_duration_seen_so_far = 0
            slot = slots[i]

            # look forward until we know if the slot is available or not
            j = i
            until slot_available || slot_unavailabile
              this_slot = slots[j]
              total_duration_seen_so_far += this_slot.end_datetime - this_slot.start_datetime
              slot_available = total_duration_seen_so_far >= requested_duration
              next_slot = slots[j+1]
              if !slot_available && next_slot # continue checking the next slot if contiguous
                slot_unavailabile = next_slot.start_datetime != this_slot.end_datetime
                j += 1
              else # no more slots to check and slot not available
                slot_unavailabile = true
              end
            end

            filtered_slots << slot if slot_available
            i += 1
          end
          filtered_slots
        end
      end
    end
  end
end
