module Leo
  module Entities
    class ClosureReasonEntity < Grape::Entity
      expose :id
      expose :order
      expose :has_note
      expose :short_description
      expose :long_description
    end
  end
end
