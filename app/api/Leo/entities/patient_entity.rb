module Leo
  module Entities
    class PatientEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :suffix, :birth_date, :sex, :family_id, :email, :role_id, :avatar_url
    end
  end
end
