module Leo
  module Entities
    class UserEntity < Grape::Entity
        expose :id, :title, :first_name, :middle_initial, :last_name, :dob, :gender, :practice_id, :family_id, :email, :primary_role, :stripe_customer_id
    end
  end
end
