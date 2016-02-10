module Leo
  module Entities
    class ShortPatientEntity < Grape::Entity
      expose :id, :title, :first_name, :last_name, :sex, :family_id, :email
      expose :role
      expose :birth_date

      private

      def role
        object.role.name
      end
    end
  end
end
