module Leo
  module Entities
    class CardEntity < Grape::Entity
      expose :id, safe: true
      expose :priority
      expose :type, as: :type_name
      expose :type_id
      expose :deep_link_card_data, using: Leo::Entities::LinkPreviewEntity, as: :card_data, if: Proc.new {|g| g[:deep_link_card_data]}
      expose :conversation_card_data, using: Leo::Entities::ConversationEntity, as: :card_data, if: Proc.new {|g| g[:conversation_card_data]}
      expose :appointment_card_data, using: Leo::Entities::AppointmentEntity, as: :card_data, if: Proc.new {|g| g[:appointment_card_data]}
    end
  end
end
