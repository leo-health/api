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
      expose :image

      private

      def image
        object.message_photo.try(:image)
      end
    end
  end
end
