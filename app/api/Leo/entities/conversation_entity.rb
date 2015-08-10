module Leo
  module Entities
    class ConversationEntity < Grape::Entity
      expose :id
      expose :staff, with: Leo::Entities::UserEntity
      expose :users, with: Leo::Entities::UserEntity
      expose :created_at
      expose :updated_at
      expose :family
      expose :last_message_created_at
      expose :state
      expose :last_closed_at
      expose :last_closed_by

      private

      def users
        object.family.members
      end
    end
  end
end
