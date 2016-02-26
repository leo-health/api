require 'airborne'
require 'rails_helper'

describe Leo::V1::Cards do
  describe "Get /api/v1/cards" do
    let!(:customer_service){ create(:user, :customer_service) }
    let(:user){ create(:user, :guardian) }
    let!(:session){ user.sessions.create }
    let!(:upcoming_appointment){create(:appointment, :future, booked_by: user, start_datetime: Time.now + 1.day)}
    let!(:past_appointment){create(:appointment, :checked_in, booked_by: user, start_datetime: Time.now - 1.day)}
    let!(:cancelled_appointment){create(:appointment, :cancelled, booked_by: user, start_datetime: Time.now) }
    let(:serializer){ Leo::Entities::CardEntity }
    let!(:response_data){[{appointment_card_data: upcoming_appointment.reload, priority: 0, type: 'appointment', type_id: 0},
                          {conversation_card_data: user.family.conversation, priority: 1, type: 'conversation', type_id: 1}]}

    def do_request
      get "/api/v1/cards", {authentication_token: session.authentication_token}
    end

    it "should return the cards of current user" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data].as_json.to_json).to eq(serializer.represent(response_data).as_json.to_json)
    end
  end
end
