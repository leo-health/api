module Leo
  module Entities
    class FamilyEntity < Grape::Entity
      expose :id
      expose :patients, with: Leo::Entities::PatientEntity
      expose :guardians, with: Leo::Entities::UserEntity
    end
  end
end
