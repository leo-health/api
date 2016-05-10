module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :suffix, :sex, :practice_id, :family_id, :email
      expose :role, with: Leo::Entities::RoleEntity
      expose :avatar do |instance, options|
        Leo::Entities::AvatarEntity.represent instance.avatar, options
      end
      expose :primary_guardian, :type, :member_type, if: Proc.new{ |u| u.guardian? }
      expose :credentials, unless: Proc.new{ |u| u.guardian? }
      expose :vendor_id, if: Proc.new{ |u| u.guardian? }

      private

      def member_type
        object.try(:member_type).try(:name)
      end

      # backward compatibility
      def type
        # Testflight front-end only shows the feed if the type is "Member"
        member_type = object.try(:member_type).try(:name).try(:to_sym)
        member_type = :Member if [:exempted, :member].include? member_type

        :Member # !!!!: remove this when the member_type changes based on payments
      end

      def device_type
        options[:device_type]
      end

      def primary_guardian
        object.primary_guardian?
      end

      def credentials
        object.staff_profile.try(:credentials)
      end
    end
  end
end
