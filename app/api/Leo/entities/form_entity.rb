module Leo
  module Entities
    class FormEntity < Grape::Entity
      expose :id, :title, :notes, :status
      expose :created_at, as: :created_datetime
      expose :updated_at, as: :updated_datetime

      expose :patient, with: Leo::Entities::UserEntity
      expose :submitted_by, with: Leo::Entities::UserEntity
      expose :completed_by, with: Leo::Entities::UserEntity
    end
  end
end
