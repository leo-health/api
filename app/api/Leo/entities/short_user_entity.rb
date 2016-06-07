module Leo
  module Entities
    class ShortUserEntity < Grape::Entity
      expose :id, :title, :first_name, :last_name, :family_id, :email
      expose :role, with: Leo::Entities::RoleEntity
      expose :credentials, unless: Proc.new{ |u| u.guardian? }
      expose :vendor_id, if: Proc.new{ |u| u.guardian? }

      private

      def credentials
        object.try(:credentials) || object.try(:staff_profile).try(:credentials)
      end
    end
  end
end
