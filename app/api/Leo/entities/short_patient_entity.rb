module Leo
  module Entities
    class ShortPatientEntity < Grape::Entity
      expose :id, :title, :first_name, :last_name, :sex, :family_id, :email, :birth_date
    end
  end
end
