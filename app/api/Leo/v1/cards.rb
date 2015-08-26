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
          appointments = Appointment.where( :booked_by_id => family.guardians.pluck(:id)).order("created_at DESC")
          cards = appointments.each_with_index.inject([]){|cards, (appointment, index)| cards << {card_data: appointment, priority: index, type: "appointment", type_id: 0}}
          present :count, appointments.count
          present :cards, cards, with: Leo::Entities::CardEntity
        end
      end
    end
  end
end
