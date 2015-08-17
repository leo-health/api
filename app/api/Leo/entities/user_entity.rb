module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :dob, :sex, :practice_id, :family_id, :email, :stripe_customer_id
      expose :credentials, if: {role_id: 5}
      expose :specialties, if: {role_id: 5}
      expose :role
      expose :role_id

      private

      def role
        object.role.name
      end

      def role_id
        object.role.id
      end
    end
  end
end
