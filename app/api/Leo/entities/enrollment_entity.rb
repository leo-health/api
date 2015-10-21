module Leo
  module Entities
    class EnrollmentEntity < Grape::Entity
      expose :id
      expose :family_id
      expose :title
      expose :first_name
      expose :middle_initial
      expose :last_name
      expose :birth_date
      expose :suffix
      expose :sex
      expose :practice_id
      #expose :practice, with: Leo::Entities::PracticeEntity
      expose :email
      expose :phone
      expose :created_at
      expose :deleted_at
      expose :updated_at
      expose :insurance_plan_id
      expose :invited_user
      expose :role_id
      expose :avatar_url
    end
  end
end
