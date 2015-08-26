module Leo
  module Entities
    class CardEntity < Grape::Entity
      expose :priority
      expose :type
      expose :type_id
      expose :card_data, with: Leo::Entities::AppointmentEntity
    end
  end
end
