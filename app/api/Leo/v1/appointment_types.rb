module Leo
  module V1
    class AppointmentTypes < Grape::API

      resource :appointment_types do

        desc "Return all appointment_types"
        before do
          authenticated
        end

        get do
          present AppointmentType.where(hidden: false).order("lower(name) DESC").all, with: Leo::Entities::AppointmentTypeEntity
        end
      end
    end
  end
end
