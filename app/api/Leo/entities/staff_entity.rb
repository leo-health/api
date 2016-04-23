module Leo
  module Entities
    class StaffEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :suffix, :sex, :practice_id
      expose :role, with: Leo::Entities::RoleEntity
      expose :avatar do |instance, options|
        Leo::Entities::AvatarEntity.represent instance.avatar, options
      end

      private

      def id
        object.try(:provider_sync_profile).try(:id) || object.id
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
