module Leo
  module Entities
    class AvatarEntity < Grape::Entity
      expose :id
      expose :avatar, with: Leo::Entities::ImageEntity, as: :url
      expose :owner_type
      expose :owner_id
      expose :created_at, as: :created_datetime
    end
  end
end
