class Leo::Entities::ConversationWithMessagesEntity < Leo::Entities::ConversationEntity
  expose :messages, with: Leo::V1::Entities::MessageEntity
end
