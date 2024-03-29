module Leo
  module Entities
    class ShortConversationEntity < Grape::Entity
      expose :id
      expose :patients, with: Leo::Entities::ShortPatientEntity
      expose :guardians, with: Leo::Entities::ShortUserEntity
      expose :primary_guardian, with: Leo::Entities::ShortUserEntity
      expose :last_message_created_at
      expose :state
      expose :last_message
      expose :escalated_to, with: Leo::Entities::ShortUserEntity, if: Proc.new{ |c| c.escalated? }

      private

      def guardians
        @guardians = object.family.guardians.order('created_at ASC')
      end

      def primary_guardian
        @guardians.first
      end

      def patients
        object.family.patients
      end

      def last_message
        object.messages.order('created_at DESC').first.try(:body) || '[image]'
      end

      def escalated_to
        EscalationNote.where(conversation: object).order('created_at ASC').last.try(:escalated_to)
      end
    end
  end
end
