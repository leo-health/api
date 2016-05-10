module Leo
  module Entities
    class ProviderLeaveEntity < Grape::Entity
      expose :start_datetime
      expose :end_datetime
    end
  end
end
