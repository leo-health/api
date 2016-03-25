module Leo
  module Entities
    class PHREntity < Grape::Entity
      expose :heights, with: Leo::Entities::VitalEntity
      expose :weights, with: Leo::Entities::VitalEntity
      expose :bmis, with: Leo::Entities::VitalEntity
      expose :allergies, with: Leo::Entities::AllergyEntity
      expose :immunizations, with: Leo::Entities::VaccineEntity
      expose :medications, with: Leo::Entities::MedicationEntity
    end
  end
end
