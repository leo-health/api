module Leo
  module Entities
    class AppointmentStatusEntity < Grape::Entity
      expose :id
      expose :description
      expose :status
    end
  end
end
