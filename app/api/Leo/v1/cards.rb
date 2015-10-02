module Leo
  module V1
    class Cards < Grape::API
      include Grape::Kaminari

      desc "Return all cards of a user"
      namespace "cards" do
        before do
          authenticated
        end

        get do
          family = Family.includes(:guardians).find(current_user.family_id)
          appointments = Appointment.where( :booked_by_id => family.guardians.pluck(:id)).order("created_at DESC")
          upcoming_appointments, past_appointment = appointments.partition{|appointment| appointment.start_datetime > Time.now}
          cards = (upcoming_appointments + [family.conversation] + past_appointment).each_with_index.inject([]) do |cards, (card, index)|
            case card.class.name
            when 'Conversation'
              cards << {conversation_card_data: card, priority: index, type: 'conversation', type_id: 1}
            when 'Appointment'
              cards << {appointment_card_data: card, priority: index, type: 'appointment', type_id: 0}
            end
          end
          present paginate(Kaminari.paginate_array(cards)), with: Leo::Entities::CardEntity
        end
      end
    end
  end
end
