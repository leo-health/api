module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :suffix, :sex, :practice_id, :family_id, :email
      expose :role, with: Leo::Entities::RoleEntity
      expose :avatar do |instance, options|
        Leo::Entities::AvatarEntity.represent instance.avatar, options
      end
      expose :type
      expose :primary_guardian, if: Proc.new{ |g| g.role.name.to_sym == :guardian }
      expose :credentials, if: Proc.new{ |g| g.role.name.to_sym == :clinical }

      private

      def device_type
        options[:device_type]
      end

      def primary_guardian
        object.family.guardians.where(['created_at < ?', object.created_at]).count < 1
      end

      def credentials
        object.provider_profile.try(:credentials)
      end
    end
  end
end
