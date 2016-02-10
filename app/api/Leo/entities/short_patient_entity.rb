module Leo
  module Entities
    class ShortPatientEntity < Grape::Entity
      expose :id, :title, :first_name, :last_name, :sex, :family_id, :email
      expose :role, with: Leo::Entities::RoleEntity
      expose :birth_date
    end
  end
end
