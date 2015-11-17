module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :suffix, :sex, :practice_id, :family_id, :email
      expose :role
      expose :role_id
      expose :avatar
      expose :type

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
