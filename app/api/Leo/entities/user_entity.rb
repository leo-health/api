module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :suffix, :sex, :practice_id, :family_id, :email, :role_id, :avatar_url
      expose :role
      expose :avatar

      private

      def avatar
        if object.avatar && options[:avatar_size]
          object.avatar.avatar.url(options[:avatar_size])
        else
          object.avatar.try(:avatar)
        end
      end

      def role
        object.role.name
      end
    end
  end
end
