module Leo
  module Entities
    class EscalationNoteEntity < Grape::Entity
      expose :id
      expose :user_conversation
      expose :escalated_by, with: Leo::Entities::UserEntity
      expose :priority
      expose :note
    end
  end
end
