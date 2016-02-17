module Leo
  module Entities
    class FamilyEntity < Grape::Entity
      expose :id
      expose :patients do |instance, options|
        Leo::Entities::PatientEntity.represent instance.patients, options
      end
      expose :guardians do |instance, options|
        Leo::Entities::UserEntity.represent instance.guardians, options
      end
    end
  end
end
