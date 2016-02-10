module Leo
  module Entities
    class ShortUserEntity < Grape::Entity
      expose :id, :title, :first_name, :last_name
      expose :role, with: Leo::Entities::RoleEntity
      expose :credentials, unless: Proc.new{ |g| g.has_role? :guardian }

      private

      def credentials
        object.staff_profile.try(:credentials)
      end
    end
  end
end
