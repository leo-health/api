module Leo
  module Entities
    class MessageEntity < Grape::Entity
      expose :id
      expose :sender_id, documentation: {type: "integer", desc: "The Leo id of the sender." }
      expose :conversation_id,  documentation: {type: "integer", desc: "The conversation id." }
      expose :body, documentation: {type: "string", desc: "The message body." }
      expose :message_type, documentation: {type: "string", desc: "The message type." }
      expose :created_at, documentation: {type: "datetime", desc: "The date/time the message was created at." }
      expose :escalated_to, with: Leo::Entities::ConversationParticipantEntity, documentation: {type: "object", desc: "The physician who the message has been escalated to." }
      expose :escalated_by, with: Leo::Entities::ConversationParticipantEntity, documentation: {type: "object", desc: "The staff who the message has been escalated by." }
      expose :escalated_at, documentation: {type: "datetime", desc: "The date/time the message was escalated at." }
      expose :resolved_requested_at, documentation: {type: "datetime", desc: "The date/time a physician marked a message as resolved." }
      expose :resolved_approved_at, documentation: {type: "datetime", desc: "The date/time a staff member approved a resolved request." }
      expose :resolved, documentation: {type: "boolean", desc: "Has the escalation been resolved?" }
      expose :read_receipts
    end
  end
end
