module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :dob, :sex, :practice_id, :family_id, :email, :stripe_customer_id
      expose :roles, with: Leo::Entities::RoleEntity
      private
        def roles
          object.roles
        end
    end
  end
end
