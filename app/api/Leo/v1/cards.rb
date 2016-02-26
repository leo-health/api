module Leo
  module V1
    class Cards < Grape::API
      desc "Return all cards of a user"
      namespace "cards" do
        before do
          authenticated
        end

        get do
          family = Family.includes(:guardians).find(current_user.family_id)
          appointments = Appointment.booked.where( booked_by_id: family.guardians.pluck(:id) )
                           .where("start_datetime > ?", Time.now).order("created_at DESC")
          cards = (appointments + [family.conversation]).each_with_index.inject([]) do |cards, (card, index)|
            case card
            when Conversation
              cards << {conversation_card_data: card, priority: index, type: 'conversation', type_id: 1}
            when Appointment
              cards << {appointment_card_data: card, priority: index, type: 'appointment', type_id: 0}
            end
          end

          present cards, with: Leo::Entities::CardEntity
        end
      end
    end
  end
end
