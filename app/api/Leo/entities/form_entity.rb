module Leo
  module Entities
    class FormEntity < Grape::Entity
      expose :id, :title, :notes, :status
      expose :created_at, as: :created_datetime
      expose :updated_at, as: :updated_datetime
      expose :image, as: :url
      expose :status
      expose :patient, with: Leo::Entities::PatientEntity
      expose :submitted_by, with: Leo::Entities::UserEntity
      expose :completed_by, with: Leo::Entities::UserEntity

      private

      def image
        Leo::Entities::ImageEntity.represent(object.image, options)
      end
    end
  end
end
