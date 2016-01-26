module Leo
  module Entities
    class AvatarEntity < Grape::Entity
      expose :id
      expose :url, with: Leo::Entities::ImageEntity
      expose :owner_type
      expose :owner_id
      expose :created_at, as: :created_datetime

      private

      def url
        image_version = DEVICE_IMAGE_SIZE_MAP[options[:device_type]] || :primary_3x
        object.avatar.send(image_version) if object.avatar.respond_to?(image_version)
      end
    end
  end
end
