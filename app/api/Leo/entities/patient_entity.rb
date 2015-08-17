module Leo
  module Entities
    class PatientEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :suffix, :sex, :family_id, :email, :role_id, :avatar_url
      expose :role
      format_with(:iso_timestamp) { |dt| dt.iso8601 }
      with_options(format_with: :iso_timestamp) do
        expose :birth_date
      end

      private

      def role
        object.role.name
      end
    end
  end
end
