module Leo
  module V1
    class Cards < Grape::API
      desc "Return all cards of a user"

      resource :route_cards do
        before do
          authenticated_and_complete
        end

        get do
          appointments = Appointment.booked
          .where(patient_id: current_user.family.patients.pluck(:id))
          .where.not(appointment_type: AppointmentType.blocked)
          .where("start_datetime > ?", Time.now).order("updated_at DESC")

          appointment_card_states = appointments.map{|appointment|
            AppointmentCardPresenter.new(appointment).present
          }.flatten

          cards = appointment_card_states # + conversation_card_states + content_card_states...
          
          {
            cards: cards,
            associated_data: {
              appointment: Leo::Entities::AppointmentEntity.represent(appointments)
            }
          }
        end
      end

      namespace "cards" do
        before do
          authenticated_and_complete
        end

        get do
          conversations = [Family.includes(:guardians).find(current_user.family_id).conversation]
          user_link_previews = current_session.feature_available?(:ContentCards) ? UserLinkPreview.where(user: current_user).published : []
          appointments = Appointment.booked
          .where(patient_id: current_user.family.patients.pluck(:id))
          .where.not(appointment_type: AppointmentType.blocked)
          .where("start_datetime > ?", Time.now).order("updated_at DESC")

          card_objects = conversations + user_link_previews + appointments
          sorted_cards = card_objects
          .sort_by(&:updated_at).reverse
          .each_with_index
          .map do |card, index|
            case card
            when UserLinkPreview
              {id: card.id, deep_link_card_data: card.link_preview, priority: index, type: 'deep_link', type_id: 2}
            when Conversation
              {conversation_card_data: card, priority: index, type: 'conversation', type_id: 1}
            when Appointment
              {appointment_card_data: card, priority: index, type: 'appointment', type_id: 0}
            end
          end

          present sorted_cards, with: Leo::Entities::CardEntity
        end

        params do
          requires :id, type: Integer, allow_blank: false
        end

        delete do
          UserLinkPreview.where(id: params[:id])
          .update_all(dismissed_at: Time.now)
        end
      end
    end
  end
end
