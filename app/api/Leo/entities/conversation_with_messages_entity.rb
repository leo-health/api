module Leo
  module Entities
    class ConversationWithMessagesEntity < Leo::Entities::ConversationEntity
      expose :messages, with: Leo::Entities::MessageEntity
    end
  end
end
