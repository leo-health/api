module Leo
  module Entities
    class UserGeneratedHealthRecordEntity < Grape::Entity
      expose :id
      expose :user, with: Leo::Entities::UserEntity
      expose :created_at
      expose :updated_at
      expose :deleted_at
      expose :note
    end
  end
end
