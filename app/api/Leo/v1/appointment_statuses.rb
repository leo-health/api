module Leo
  module V1
    class AppointmentStatuses < Grape::API
      resource :appointment_statuses do
        desc "Return all open slots for a specified provider"
        before do
          authenticated
        end

        get do
          present :appointment_statuses, AppointmentStatus.all
        end
      end
    end
  end
end
