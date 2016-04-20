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

          provider = User.find(params[:provider_id]).provider_sync_profile
          slots = Slot.free.where(provider_sync_profile: provider).between(start_date, end_date)
          existing_appointment = Appointment.find_by_id(params[:appointment_id])
          if existing_appointment.try(:provider_id) == params[:provider_id]
              slots += [existing_appointment]
          end
          schedule =  ProviderSchedule.find_by(athena_provider_id: provider.athena_id)

          slots = slots.reject { |slot| slot.start_datetime + appointment_type.duration.minutes > schedule.end_time_for_date(slot.end_datetime) }

          [{ provider_id: params[:provider_id], slots: slots.map { |slot| {start_datetime: slot.start_datetime, duration: slot.duration} } }]

          # TODO: add in existing appointment

          # open_slots = []
          #
          # appointment = Appointment.find_by_id(params[:appointment_id])
          # if appointment.try(:provider_id) == params[:provider_id]
          #     open_slots += [AppointmentSlotsHelper::OpenSlot.new(appointment.start_datetime, appointment.duration)]
          # end
          # type = AppointmentType.find(params[:appointment_type_id])
          # provider = User.find(params[:provider_id])
          #
          # osp = AppointmentSlotsHelper::OpenSlotsProcessor.new
          # start_date.upto(end_date) do |date|
          #   open_slots += osp.get_open_slots(athena_provider_id: provider.provider_sync_profile.athena_id, date: date, durations: [ type.duration ])
          # end
          #
          # current_datetime = DateTime.now
          # filtered_open_slots = open_slots.select { |x| x.start_datetime >  (current_datetime + Appointment::MIN_INTERVAL_TO_SCHEDULE)}
          # [{ provider_id: params[:provider_id], slots: filtered_open_slots }]
        end
      end
    end
  end
end
