module Leo
  module Entities
    class PatientInsuranceEntity < Grape::Entity
      expose :plan_name, :plan_phone, :policy_number, :primary, :irc_name
      expose :holder_last_name, :holder_first_name, :holder_middle_name
    end
  end
end
