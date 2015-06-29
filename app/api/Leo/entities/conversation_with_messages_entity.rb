module Leo
  module Entities
    class ConversationWithMessagesEntity < Leo::Entities::ConversationEntity
      expose :messages, with: Leo::V1::Entities::MessageEntity
    end
  end
end
