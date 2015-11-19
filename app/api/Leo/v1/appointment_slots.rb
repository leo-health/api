module Leo
  module V1
    class AppointmentSlots < Grape::API
      resource :appointment_slots do
        # get "provider/{athena_provider_id}/appointment_slots"
        # get "appointment_slots?start_date=01/01/2015&end_date=02/01/2015&appointment_type_id=2&provider_id=6"

        desc "Return all open slots for a specified provider"
        before do
          authenticated
        end
        params do
          requires :start_date, type: String, desc: "Start date", allow_blank: false
          requires :end_date, type: String, desc: "End date", allow_blank: false
          requires :appointment_type_id, type: Integer, desc: "Appointment Type", allow_blank: false
          requires :provider_id, type: Integer, desc: "Provider Id", allow_blank: false
        end
        get do
          start_date = Date.strptime(params[:start_date], "%m/%d/%Y")
          end_date = Date.strptime(params[:end_date], "%m/%d/%Y")

          open_slots = []

          type = AppointmentType.find(params[:appointment_type_id])
          provider = User.find(params[:provider_id])

          osp = AppointmentSlotsHelper::OpenSlotsProcessor.new
          start_date.upto(end_date) do |date|
            open_slots = open_slots + osp.get_open_slots(athena_provider_id: provider.provider_profile.athena_id, date: date, durations: [ type.duration ])
          end

          current_datetime = DateTime.now
          filtered_open_slots = open_slots.select { |x| x.start_datetime >  current_datetime }

            [
              {
                provider_id: params[:provider_id],
                slots: filtered_open_slots
              }
            ]
        end
      end
    end
  end
end
