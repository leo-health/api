module Leo
  module Entities
    class ClosureReasonEntity < Grape::Entity
      expose :id
      expose :reason_order
      expose :user_input
      expose :short_description
      expose :long_description
    end
  end
end
