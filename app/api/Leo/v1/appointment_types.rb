module Leo
  module V1
    class AppointmentTypes < Grape::API

      resource :appointment_types do

        desc "Return all appointment_types"
        before do
          authenticated
        end

        get do
          appointment_types = AppointmentType.where(hidden: false)

          # if no appointment types are marked as visible, display all appointment types
          if appointment_types.count == 0
            appointment_types = AppointmentType.all
          end
          present appointment_types.order("lower(name) DESC"), with: Leo::Entities::AppointmentTypeEntity
        end
      end
    end
  end
end
