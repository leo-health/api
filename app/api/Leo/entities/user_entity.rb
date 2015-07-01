module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id
      expose :title
      expose :first_name
      expose :middle_initial
      expose :last_name
      expose :dob
      expose :gender
      expose :practice_id
      expose :family_id
      expose :email
      expose :primary_role
      expose :stripe_customer_id
    end
  end
end
