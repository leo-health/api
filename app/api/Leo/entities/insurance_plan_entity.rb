module Leo
  module Entities
    class InsurancePlanEntity < Grape::Entity
      expose :id
      expose :insurer_id
      expose :plan_name
      expose :athena_id
      expose :created_at
      expose :updated_at
    end
  end
end
