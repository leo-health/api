module Leo
  module Entities
    class InsurerEntity < Grape::Entity
      expose :id
      expose :insurer_name
      expose :phone
      expose :fax
      expose :insurance_plans, with: Leo::Entities::InsurancePlanEntity

      private

      def insurance_plans
        object.insurance_plans.where(active: true)
      end
    end
  end
end
