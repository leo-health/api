module Leo
  module Entities
    class AvatarEntity < Grape::Entity
      expose :id
      expose :url
      expose :owner_type
      expose :owner_id
      expose :created_at, as: :created_datetime

      private

      def url
        Leo::Entities::ImageEntity.represent(object.avatar, options)
      end
    end
  end
end
