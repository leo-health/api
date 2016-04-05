require 'airborne'
require 'rails_helper'

describe Leo::V1::Cards do

  before { allow_any_instance_of(SyncServiceHelper::Syncer).to receive(:sync_athena_appointments_for_family).and_return(true) }

  describe "Get /api/v1/cards" do
    let(:user){ create(:user, :guardian) }
    let(:session){ user.sessions.create }
    let!(:upcoming_appointment){create(:appointment, :future, booked_by: user, start_datetime: Time.now + 1.day, updated_at: Time.now - 1.day)}
    let!(:updated_upcoming_appointment){create(:appointment, :future, booked_by: user, start_datetime: Time.now + 1.day, updated_at: Time.now - 2.day)}
    let!(:past_appointment){create(:appointment, :checked_in, booked_by: user, start_datetime: Time.now - 1.day)}
    let!(:cancelled_appointment){create(:appointment, :cancelled, booked_by: user, start_datetime: Time.now) }
    let(:serializer){ Leo::Entities::CardEntity }
    let(:response_data){[{conversation_card_data: user.family.conversation, priority: 0, type: 'conversation', type_id: 1},
                          {appointment_card_data: upcoming_appointment.reload, priority: 1, type: 'appointment', type_id: 0},
                          {appointment_card_data: updated_upcoming_appointment.reload, priority: 2, type: 'appointment', type_id: 0}]}

    def do_request
      get "/api/v1/cards", {authentication_token: session.authentication_token}
    end

    it "should return the cards of current user" do
      expect{do_request}.to change{Delayed::Job.count}.by(1)
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data].as_json.to_json).to eq(serializer.represent(response_data).as_json.to_json)
    end
  end
end
