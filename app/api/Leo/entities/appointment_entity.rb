module Leo
  module Entities
    class AppointmentEntity < Grape::Entity
      expose :id
      expose :created_at, as: :created_datetime
      expose :start_datetime
      expose :appointment_status, with: Leo::Entities::AppointmentStatusEntity, as: :status
      expose :appointment_type, with: Leo::Entities::AppointmentTypeEntity
      expose :notes
      expose :booked_by, with: Leo::Entities::UserEntity
      expose :provider, with: Leo::Entities::ProviderEntity
      expose :patient, with: Leo::Entities::PatientEntity
      expose :practice, with: Leo::Entities::PracticeEntity

      def appointment_type
        object.appointment_type.user_facing_appointment_type || object.appointment_type
      end
    end
  end
end
