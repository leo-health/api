module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id
      expose :title, :first_name, :middle_initial, :last_name, :suffix, :sex, :practice_id, :email
      expose :role, with: Leo::Entities::RoleEntity
      expose :avatar do |instance, options|
        Leo::Entities::AvatarEntity.represent instance.avatar, options
      end
      expose :type
      expose :primary_guardian, if: Proc.new{ |u| u.guardian? }
      expose :credentials, unless: Proc.new{ |u| u.guardian? }
      expose :vendor_id, if: Proc.new{ |u| u.guardian? }
      expose :family_id, if: Proc.new{ |u| u.guardian? }

      private

      def device_type
        options[:device_type]
      end

      def primary_guardian
        object.primary_guardian?
      end

      def credentials
        object.try(:credentials) || object.try(:staff_profile).try(:credentials)
      end
    end
  end
end
