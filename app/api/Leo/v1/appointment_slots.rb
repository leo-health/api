module Leo
  module V1
    class AppointmentSlots < Grape::API
      resource :appointment_slots do
        # get "/appointment_slots"
        desc "Return all open slots for a specified practice"
        params do
          requires :athena_practice_id, type: Integer, desc: "Athena practice Id"
          requires :start_date, type: Date, desc: "Start date"
          requires :end_date, type: Date, desc: "End date"
          requires :appointment_type_id, type: Integer,  desc: "Appointment type id"
        end
        get do
          {
            appointment_slots: [] #array of AppointmentSlot objects
          }
        end
      end
    end
  end
end
