module Leo
  module Entities
    class AppointmentEntity < Grape::Entity
      expose :id
      expose :created_at, as: :created_datetime
      expose :start_datetime
      expose :status
      expose :appointment_type, with: Leo::Entities::AppointmentTypeEntity
      expose :notes
      expose :booked_by, with: Leo::Entities::UserEntity
      expose :provider, with: Leo::Entities::UserEntity
      expose :patient, with: Leo::Entities::PatientEntity
    end
  end
end
