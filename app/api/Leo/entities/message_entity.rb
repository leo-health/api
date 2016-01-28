module Leo
  module Entities
    class MessageEntity < Grape::Entity
      expose :id
      expose :sender, with: Leo::Entities::UserEntity
      expose :conversation_id
      expose :body
      expose :type_name
      expose :created_at
      expose :read_receipts

      private

      def body
        if object.type_name == 'text'
          object.body
        else
          image_version = DEVICE_IMAGE_SIZE_MAP[options[:device_type]] || :primary_3x
          if object.message_photo.image.respond_to?(image_version)
           Leo::Entities::ImageEntity.represent(object.message_photo.image.send(image_version))
          end
        end
      end
    end
  end
end
