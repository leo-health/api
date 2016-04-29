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
          requires :provider_id, type: Integer, desc: "Provider Id", allow_blank: false
          optional :appointment_id, type: Integer, desc: "Existing appointment to reschedule", allow_blank: false
        end

        get do
          appointment_type = AppointmentType.find(params[:appointment_type_id])
          start_date = [Date.strptime(params[:start_date], "%m/%d/%Y"), Time.now + Appointment::MIN_INTERVAL_TO_SCHEDULE].max
          end_date = Date.strptime(params[:end_date], "%m/%d/%Y")

          user = User.find_by(role: Role.clinical, id: params[:provider_id])
          error!({error_code: 422, error_message: "Provider with id #{params[:provider_id]} does not exist" }, 422) unless user

          provider = user.provider_sync_profile
          slots = Slot.free.where(provider_sync_profile: provider).between(start_date, end_date.end_of_day)
          
          # Allow rescheduling for the same time if the current_user owns the appointment
          if existing_appointment = Appointment.find_by_id(params[:appointment_id])
            same_family_as_current_user = existing_appointment.patient.family_id == current_user.family_id
            same_provider = existing_appointment.provider_sync_profile_id == params[:provider_id]
            attempting_to_reschedule = same_family_as_current_user && same_provider
            if attempting_to_reschedule
              slots += [existing_appointment]
            end
          end
          schedule =  ProviderSchedule.find_by(athena_provider_id: provider.athena_id)

          filtered_slots = slots.reject { |slot| slot.start_datetime + appointment_type.duration.minutes > schedule.end_time_for_date(slot.end_datetime) }
          slots_json = filtered_slots.map { |slot| {start_datetime: slot.start_datetime, duration: slot.duration} }

          [{ provider_id: params[:provider_id], slots: slots_json }]
        end
      end
    end
  end
end
