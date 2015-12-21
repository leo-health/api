module Leo
  module Entities
    class FullMessageEntity < Grape::Entity
      expose :id
      expose :type_name, if: Proc.new {|g|g.class.name == 'Message'}
      expose :message_body
      expose :message_type
      expose :note
      expose :escalated_to, with: Leo::Entities::UserEntity
      expose :created_by, with: Leo::Entities::UserEntity
      expose :image, if: Proc.new {|g|g.class.name == 'Message'}
      expose :created_at

      private

      def image
        object.message_photo.try(:image)
      end

      def conversation_id
        if object.class == EscalationNote
          object.user_conversation.conversation
        else
          object.conversation.id
        end
      end

      def created_by
        case object
        when Message
          object.sender
        when EscalationNote
          object.escalated_by
        when ClosureNote
          object.closed_by
        end
      end

      def message_body
        object.body if object.class == Message
      end

      def message_type
        case object
        when Message
          :message
        when EscalationNote
          :escalation
        when ClosureNote
          :close
        end
      end

      def escalated_to
        object.user_conversation.staff if object.class == EscalationNote
      end

      def note
        unless object.class == Message
          object.note
        end
      end
    end
  end
end
