require 'airborne'
require 'rails_helper'

describe Leo::V1::Cards do
  let(:user){ create(:user, :guardian) }
  let(:session){ user.sessions.create(device_type: "iPhone 6", device_token: "user2_device_token", platform: "ios", client_version: "1.4.1") }
  let!(:link_preview){create(:link_preview, :referral)}
  let!(:user_link_preview){create(:user_link_preview,
    user: user,
    link_preview: link_preview
  )}
  let!(:dismissed_user_link_preview){create(:user_link_preview,
    user: user,
    link_preview: link_preview,
    dismissed_at: 1.hour.ago
  )}

  describe "Get /api/v1/cards" do
    let!(:upcoming_appointment){create(:appointment, :future, booked_by: user, start_datetime: Time.now + 1.day, updated_at: Time.now - 1.day)}
    let!(:updated_upcoming_appointment){create(:appointment, :future, booked_by: user, start_datetime: Time.now + 1.day, updated_at: Time.now - 2.day)}
    let!(:past_appointment){create(:appointment, :checked_in, booked_by: user, start_datetime: Time.now - 1.day)}
    let!(:cancelled_appointment){create(:appointment, :cancelled, booked_by: user, start_datetime: Time.now) }
    let(:serializer){ Leo::Entities::CardEntity }
    let(:response_data){[
      {id: user_link_preview.id, deep_link_card_data: link_preview, priority: 0, type: 'deep_link', type_id: 2},
      {conversation_card_data: user.reload.family.conversation, priority: 1, type: 'conversation', type_id: 1},
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

      body_json = body[:data].as_json.to_json
      expected_json = serializer.represent(response_data).as_json.to_json
      expect(body_json).to eq(expected_json)
    end
  end

  describe "DELETE /api/v1/cards" do
    it "deletes the specified card" do
      delete "/api/v1/cards", {authentication_token: session.authentication_token, id: user_link_preview.id}
      expect(response.status).to eq(200)
      expect(UserLinkPreview.published.count).to eq(0)
    end
  end
end
