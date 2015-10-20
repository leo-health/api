module Leo
  module V1
    class Notes < Grape::API
      namespace 'conversations/:conversation_id' do
        before do
          authenticated
          @conversation = Conversation.find(params[:conversation_id])
        end

        desc 'return all the escalation_notes and closure_notes of a conversation'
        get 'escalation_notes' do
          authorize! :read, EscalationNote
          escalation_notes = EscalationNote.includes(:user_conversation).where(user_conversations: {conversation_id: @conversation.id})
          closure_notes = @conversation.closure_notes
          full_messages =(messages + close_conversation_notes + escalation_notes).sort{|x, y|y.created_at <=> x.created_at}
          present :escalation_notes, escalation_notes, with: Leo::Entities::EscalationNoteEntity
        end
      end
    end
  end
end
