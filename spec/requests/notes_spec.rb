require 'airborne'
require 'rails_helper'

describe Leo::V1::Notes do
  let(:clinical){ create(:user, :clinical) }
  let(:conversation){ create(:conversation, state: :open) }
  let(:customer_service){ create(:user, :customer_service) }
  let(:session){ clinical.sessions.create }
  let(:serializer){ Leo::Entities::FullMessageEntity }

  describe 'Get /api/v1/notes/:id' do
    before do
      escalate_params = {escalated_to: clinical, note: "note", priority: 1, escalated_by: customer_service}
      conversation.escalate!(escalate_params)
      @note = EscalationNote.first
    end

    def do_request
      note_params = { authentication_token: session.authentication_token, note_type: "escalation" }
      get "/api/v1/notes/#{@note.id}", note_params
    end

    it 'should return the requested note' do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:note].as_json.to_json).to eq(serializer.represent(@note).as_json.to_json)
    end
  end
end
