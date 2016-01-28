module Leo
  module Entities
    class FullMessageEntity < Grape::Entity
      expose :id
      expose :type_name, if: Proc.new {|g|g.class.name == 'Message'}
      expose :body
      expose :message_type
      expose :note
      expose :escalated_to, with: Leo::Entities::ShortUserEntity
      expose :created_by, with: Leo::Entities::ShortUserEntity
      expose :created_at

      private

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

      def body
        if object.class == Message
          if object.type_name == 'text'
            object.body
          else
            Leo::Entities::ImageEntity.represent(object.message_photo.image)
          end
        end
      end

      def message_type
        case object
          when Message
          if object.sender.role.name == 'bot'
            :bot_message
          else
            :message
          end
        when EscalationNote
          :escalation
        when ClosureNote
          :close
        end
      end

      def escalated_to
        object.escalated_to if object.class == EscalationNote
      end

      def note
        unless object.class == Message
          object.note
        end
      end
    end
  end
end
