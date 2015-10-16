module Leo
  module Entities
    class FullMessageEntity < Grape::Entity
      expose :id
      expose :created_by, with: Leo::Entities::UserEntity
      expose :message_body
      expose :created_at
      expose :message_type
      expose :escalated_to, with: Leo::Entities::UserEntity

      private

      def conversation_id
        if object.class.name == 'EscalationNote'
          object.user_conversation.conversation
        else
          object.conversation.id
        end
      end

      def created_by
        case object.class.name
        when 'Message'
          object.sender
        when 'EscalationNote'
          object.escalated_by
        when 'ClosureNote'
          object.closed_by
        end
      end

      def message_body
        object.body if object.class.name == 'Message'
      end

      def message_type
        case object.class.name
        when 'Message'
          :message
        when 'EscalationNote'
          :escalation
        when 'ClosureNote'
          :close
        end
      end

      def escalated_to
        object.class.name == "EscalationNote" ? object.user_conversation.staff : nil
      end
    end
  end
end
