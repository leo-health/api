module Leo
  module Entities
    class FormEntity < Grape::Entity
      expose :id, :title, :notes, :status
      expose :created_at, as: :created_datetime
      expose :updated_at, as: :updated_datetime
      expose :image
      expose :status
      expose :patient, with: Leo::Entities::PatientEntity
      expose :submitted_by, with: Leo::Entities::UserEntity
      expose :completed_by, with: Leo::Entities::UserEntity

      private

      def image
        uri = URI(object.image.url) if object.image
        Rack::Utils.parse_query(uri.query).merge(base_url:"#{uri.scheme}://#{uri.host}") if uri
      end
    end
  end
end
