module Leo
  module Entities
    class ShortUserEntity < Grape::Entity
      expose :id, :title, :first_name, :last_name
      expose :role
      expose :credentials, unless: Proc.new{ |g| g.has_role? :guardian }

      private

      def role
        object.role.name
      end

      def credentials
        object.staff_profile.try(:credentials)
      end
    end
  end
end
