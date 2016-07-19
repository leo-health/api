module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id
      expose :title, :first_name, :middle_initial, :last_name, :suffix, :sex, :practice_id, :email
      expose :role, with: Leo::Entities::RoleEntity
      expose :avatar do |instance, options|
        Leo::Entities::AvatarEntity.represent instance.avatar, options
      end
      expose :primary_guardian, :type, :membership_type, :stripe_customer_id, :vendor_id, :family_id, :phone, :onboarding_group, if: Proc.new{ |u| u.guardian? }
      expose :credentials, unless: Proc.new{ |u| u.guardian? }
      expose :onboarding_group

      private

      def onboarding_group
        object.try(:onboarding_group)
      end

      def membership_type
        object.try(:membership_type)
      end

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
