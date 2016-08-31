module Leo
  module V1
    class Cards < Grape::API
      desc "Return all cards of a user"
      namespace "cards" do
        before do
          authenticated_and_complete
        end

        get do
          family = Family.includes(:guardians).find(current_user.family_id)

          deep_link_notifications = UserLinkPreview.where(user: current_user).published

          appointments = Appointment.booked
          .where(patient_id: current_user.family.patients.pluck(:id))
          .where.not(appointment_type: AppointmentType.blocked)
          .where("start_datetime > ?", Time.now).order("updated_at DESC")

          card_objects = sort_cards(deep_link_notifications + appointments + [family.conversation])
          sorted_cards = card_objects.each_with_index.inject([]) do |cards, (card, index)|
            case card
            when UserLinkPreview
              cards << {id: card.id, deep_link_card_data: card.link_preview, priority: index, type: 'deep_link', type_id: 2}
            when Conversation
              cards << {conversation_card_data: card, priority: index, type: 'conversation', type_id: 1}
            when Appointment
              cards << {appointment_card_data: card, priority: index, type: 'appointment', type_id: 0}
            end
          end

          present sorted_cards, with: Leo::Entities::CardEntity
        end

        params do
          requires :id, type: Integer, allow_blank: false
        end

        delete do
          UserLinkPreview.where(id: params[:id]).update_all(dismissed_at: Time.now)
        end
      end

      helpers do
        def sort_cards(cards)
          count = cards.count
          return cards if cards.count < 2
          left, right = cards.take(count/2), cards.drop(count/2)
          sorted_left, sorted_right = sort_cards(left), sort_cards(right)
          merge(sorted_left, sorted_right)
        end

        def merge(left, right)
          result = []
          while left.count > 0 && right.count > 0
            if left.first.updated_at >= right.first.updated_at
              result << left.shift
            else
              result << right.shift
            end
          end
          result + left + right
        end
      end
    end
  end
end
