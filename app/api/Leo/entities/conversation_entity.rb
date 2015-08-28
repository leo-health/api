module Leo
  module Entities
    class ConversationEntity < Grape::Entity
      expose :id
      expose :staff, with: Leo::Entities::UserEntity
      expose :users do
        expose :guardians, with: Leo::Entities::UserEntity
        expose :patients, with: Leo::Entities::PatientEntity
      end
      expose :created_at
      expose :updated_at
      expose :family
      expose :last_message_created_at
      expose :status
      expose :last_closed_at
      expose :last_closed_by

      private

      def guardians
        object.family.guardians
      end

      def patients
        object.family.patients
      end
    end
  end
end
