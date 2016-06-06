module Leo
  module Entities
    class PatientEntity < Grape::Entity
      expose :id, :title, :first_name, :last_name, :sex, :family_id, :email, :patient_enrollment_id
      format_with(:iso_timestamp) { |dt| dt.iso8601 }
      with_options(format_with: :iso_timestamp) do
        expose :birth_date
      end

      expose :avatar do |instance, options|
        Leo::Entities::AvatarEntity.represent instance.current_avatar, options
      end
    end
  end
end
