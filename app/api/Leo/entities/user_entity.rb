module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :sex, :practice_id, :family_id, :email, :stripe_customer_id, :role_id
      expose :role

      private

      def role
        object.role.name
      end
    end
  end
end
