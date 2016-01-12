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
          image = object.message_photo.try(:image)
          uri = URI(image.url) if image
          Rack::Utils.parse_query(uri.query).merge(base_url:"#{uri.scheme}://#{uri.host}") if uri
        end
      end
    end
  end
end
