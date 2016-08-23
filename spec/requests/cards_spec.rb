require 'airborne'
require 'rails_helper'

describe Leo::V1::Cards do
  let(:user){ create(:user, :guardian) }
  let(:session){ user.sessions.create }
  let!(:deep_link_card){create(:deep_link_card)}
  let!(:card_notification){create(:card_notification, user: user)}

  describe "Get /api/v1/cards" do
    let!(:upcoming_appointment){create(:appointment, :future, booked_by: user, start_datetime: Time.now + 1.day, updated_at: Time.now - 1.day)}
    let!(:updated_upcoming_appointment){create(:appointment, :future, booked_by: user, start_datetime: Time.now + 1.day, updated_at: Time.now - 2.day)}
    let!(:past_appointment){create(:appointment, :checked_in, booked_by: user, start_datetime: Time.now - 1.day)}
    let!(:cancelled_appointment){create(:appointment, :cancelled, booked_by: user, start_datetime: Time.now) }
    let(:serializer){ Leo::Entities::CardEntity }
    let(:response_data){[
      {id: card_notification.id, deep_link_card_data: deep_link_card, priority: 0, type: 'deep_link', type_id: 2},
      {conversation_card_data: user.family.conversation, priority: 1, type: 'conversation', type_id: 1},
      {appointment_card_data: upcoming_appointment.reload, priority: 2, type: 'appointment', type_id: 0},
      {appointment_card_data: updated_upcoming_appointment.reload, priority: 3, type: 'appointment', type_id: 0}]}

    def do_request
      get "/api/v1/cards", {authentication_token: session.authentication_token}
    end

    context "user is incomplete" do
      before do
        user.first_name = nil
        user.set_incomplete!
      end

      it "should return an authentication error" do
        do_request
        expect(response.status).to eq(401)
      end
    end

    it "should return the cards of current user" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data].as_json.to_json).to eq(serializer.represent(response_data).as_json.to_json)
    end
  end

  describe "DELETE /api/v1/cards" do
    it "deletes the specified card" do
      delete "/api/v1/cards", {authentication_token: session.authentication_token, id: card_notification.id}
      expect(response.status).to eq(200)
      expect(CardNotification.count).to eq(0)
    end
  end
end
