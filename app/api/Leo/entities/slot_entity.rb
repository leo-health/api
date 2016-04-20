module Leo
  module Entities
    class SlotEntity < Grape::Entity
      expose :id
      expose :start_datetime
      expose :duration
    end
  end
end
