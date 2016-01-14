module Leo
  module Entities
    class FormEntity < Grape::Entity
      expose :id, :title, :notes, :status
      expose :created_at, as: :created_datetime
      expose :updated_at, as: :updated_datetime
      expose :image, with: Leo::Entities::ImageEntity, as: :url
      expose :status
      expose :patient, with: Leo::Entities::PatientEntity
      expose :submitted_by, with: Leo::Entities::UserEntity
      expose :completed_by, with: Leo::Entities::UserEntity
    end
  end
end
