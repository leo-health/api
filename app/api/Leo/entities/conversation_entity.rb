module Leo
  module Entities
    class ConversationEntity < Grape::Entity
      expose :id
      expose :staff, with: Leo::Entities::ShortUserEntity
      expose :users do
        expose :guardians, with: Leo::Entities::ShortUserEntity
        expose :patients, with: Leo::Entities::PatientEntity
      end
      expose :primary_guardian, with: Leo::Entities::ShortUserEntity
      expose :created_at
      expose :updated_at
      expose :family
      expose :last_message_created_at
      expose :state
      expose :last_message
      expose :messages
      expose :message_count

      private

      def message_count
        object.messages.count
      end

      def primary_guardian
        object.family.guardians.order('created_at ASC').first
      end

      def guardians
        object.family.guardians
      end

      def patients
        object.family.patients
      end

      def last_message
        Leo::Entities::MessageEntity.represent(object.messages.order('created_at DESC').first, options)
      end

      def messages
        Leo::Entities::MessageEntity.represent(object.messages.order('created_at ASC').last(MESSAGE_PAGE_SIZE), options)
      end
    end
  end
end
