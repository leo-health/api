module Leo
  module Entities
    class MessageEntity < Grape::Entity
      expose :id
      expose :sender_id
      expose :conversation_id
      expose :body
      expose :message_type
      expose :created_at
      expose :escalated_to, with: Leo::Entities::UserEntity
      expose :escalated_by, with: Leo::Entities::UserEntity
      expose :escalated_at
      expose :read_receipts
    end
  end
end
