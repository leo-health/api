class Leo::Entities::ConversationEntity < Grape::Entity
  expose :id
  expose :participants, with: Leo::Entities::ConversationParticipantEntity
  expose :created_at
  expose :family
  expose :last_message_created
  expose :archived
  expose :archived_at
  expose :archived_by
end
