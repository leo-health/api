module Leo
  module Entities
    class ShortConversationEntity < Grape::Entity
      expose :id
      expose :patients, with: Leo::Entities::ShortUserEntity
      expose :primary_guardian, with: Leo::Entities::ShortUserEntity
      expose :guardians, with: Leo::Entities::ShortUserEntity
      expose :last_message_created_at
      expose :state
      expose :last_message

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
        object.messages.order('created_at DESC').first.body
      end
    end
  end
end
