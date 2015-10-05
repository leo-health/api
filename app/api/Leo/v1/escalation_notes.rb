module Leo
  module V1
    class EscalationNotes < Grape::API
      namespace 'conversations/:conversation_id' do
        before do
          authenticated
        end

        desc 'return all the escalation_notes of a conversation'
        params do
          requires :conversation_id, type: Integer
        end

        get 'escalation_notes' do
          escalation_notes = EscalationNote.includes(:user_conversation).where(user_conversations: {conversation_id: params[:conversation_id]})
          present :escalation_notes, escalation_notes
        end
      end
    end
  end
end
