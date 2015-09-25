module Leo
  module Entities
    class PublicActivityEntity < Grape::Entity
      expose :id
      expose :trackable_id
      expose :trackable_type
      expose :owner, with: Leo::Entities::UserEntity
      expose :key
      expose :created_at
      expose :updated_at

      private

      def owner
        User.find(object.owner_id)
      end
    end
  end
end
