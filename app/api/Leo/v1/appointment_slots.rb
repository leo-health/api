module Leo
  module V1
    class AppointmentSlots < Grape::API
      resource :provider do
        route_param :athena_provider_id, type: Integer do
          resource :appointment_slots do
            # get "provider/{athena_provider_id}/appointment_slots"
            desc "Return all open slots for a specified provider"
            params do
              requires :start_date, type: Date, desc: "Start date", allow_blank: false
              requires :end_date, type: Date, desc: "End date", allow_blank: false
            end
            get do
              open_slots = []

              appointment_durations = []
              AppointmentType.all.each { |appt_type| appointment_durations.push(appt_type.duration) }

              osp = AppointmentSlotsHelper::OpenSlotsProcessor.new()
              params[:start_date].upto(params[:end_date]) do |date|
                open_slots = open_slots + osp.get_open_slots(athena_provider_id: params[:athena_provider_id], date: date, durations: appointment_durations)
              end

              {
                data: [
                  {
                    provider_id: params[:athena_provider_id],
                    slots: open_slots
                  }
                ]
              }
            end
          end
        end
      end
    end
  end
end
