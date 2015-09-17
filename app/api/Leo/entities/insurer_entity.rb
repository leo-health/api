module Leo
  module Entities
    class InsurerEntity < Grape::Entity
      expose :id
      expose :insurer_name
      expose :phone
      expose :fax
      expose :insurance_plans

      private

      def insurance_plans
        object.insurance_plans
      end
    end
  end
end
