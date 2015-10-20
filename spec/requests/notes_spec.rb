require 'airborne'
require 'rails_helper'

describe Leo::V1::Notes do
  let(:clinical){ create(:user, :clinical) }
  let(:conversation){ create(:conversation, state: :open) }
  let(:customer_service){ create(:user, :customer_service) }
  let(:session){ clinical.sessions.create }
  let(:serializer){ Leo::Entities::EscalationNoteEntity }

  describe 'Get /api/v1/conversations/:conversation_id/notes' do
    def do_request
      escalation_notes_params = { authentication_token: session.authentication_token, conversation_id: conversation.id }
      get "/api/v1/conversations/#{conversation.id}/escalation_notes", escalation_notes_params
    end

    before do
      escalate_params = {escalated_to: clinical, note: "note", priority: 1, escalated_by: customer_service}
      conversation.escalate!(escalate_params)
    end

    it 'should return all the escalation notes belongs to the conversation' do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:escalation_notes].as_json.to_json).to eq(serializer.represent([EscalationNote.first]).as_json.to_json)
    end
  end
end
