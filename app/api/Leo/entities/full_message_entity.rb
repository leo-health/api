module Leo
  module Entities
    class FullMessageEntity < Grape::Entity
      expose :id
      expose :created_by, with: Leo::Entities::UserEntity
      expose :text_field
      expose :created_at
      expose :message_type
      expose :escalated_to, with: Leo::Entities::UserEntity

      private

      def created_by
        case object.class.name
        when 'Message'
          object.sender
        when 'EscalationNote'
          object.escalated_by
        when 'CloseConversationNote'
          object.closed_by
        end
      end

      def text_field
        case object.class.name
        when 'Message'
          object.body
        when 'EscalationNote'
          object.note
        when 'CloseConversationNote'
          object.note
        end
      end

      def message_type
        case object.class.name
        when 'Message'
          :message
        when 'EscalationNote'
          :escalation
        when 'CloseConversationNote'
          :close
        end
      end

      def escalated_to
        object.class.name == "EscalationNote" ? object.user_conversation.staff : nil
      end
    end
  end
end
