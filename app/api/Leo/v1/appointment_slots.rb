module Leo
  module V1
    class AppointmentSlots < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      rescue_from :all, :backtrace => true
      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter
      default_error_status 400

      resource :appointment_slots do
        # get "/appointment_slots"
        desc "Return all open slots for a specified provider"
        params do
          requires :athena_provider_id, type: Integer, desc: "Athena provider Id"
          requires :start_date, type: Date, desc: "Start date"
          requires :end_date, type: Date, desc: "End date"
        end
        get do
          open_slots = []

          #todo: don't hardcode appointment times
          osp = AppointmentSlotsHelper::OpenSlotsProcessor.new()
          params[:start_date].upto(params[:end_date]) do |date|
            open_slots = open_slots + osp.get_open_slots(athena_provider_id: params[:athena_provider_id], date: date, durations: [15, 20, 30, 60])
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
