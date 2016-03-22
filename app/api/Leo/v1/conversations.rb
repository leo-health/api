module Leo
  module V1
    class Conversations < Grape::API
      include Grape::Kaminari

      resource :conversations do
        before do
          authenticated
        end

        desc "Close a conversation"
        namespace ':id/close' do
          params do
            requires :note, type: String
          end

          put do
            conversation = Conversation.find(params[:id])
            authorize! :update, conversation
            close_params = {closed_by: current_user, note: params[:note]}
            if conversation.close!(close_params)
              closure_note = conversation.last_closure_note
              present :conversation_id, closure_note.conversation_id
              present :created_by, current_user
              present :note, closure_note.note
              present :message_type, :close
              present :id, closure_note.id
            else
              error!({error_code: 422, error_message: "can't close the conversation" }, 422)
            end
          end
        end

        desc 'escalate a conversation'
        namespace ':id/escalate' do
          params do
            requires :escalated_to_id, type: Integer, allow_blank: false
            requires :priority, type: Integer, allow_blank: false
            optional :note, type: String
          end

          put do
            conversation = Conversation.find(params[:id])
            authorize! :update, conversation
            escalated_to = User.find(params[:escalated_to_id])
            escalate_params = {escalated_to: escalated_to, note: params[:note], priority: params[:priority], escalated_by: current_user}
            if conversation.escalate!(escalate_params)
              escalation_note = conversation.last_escalation_note
              present :escalated_to, escalated_to,  with: Leo::Entities::UserEntity
              present :note, escalation_note.note
              present :conversation_id, escalation_note.conversation_id
              present :created_by, current_user
              present :message_type, :escalation
              present :id, escalation_note.id
            else
              error!({error_code: 422, error_message: "can't escalate the conversation" }, 422)
            end
          end
        end

        desc "Get all the conversations by state"
        paginate per_page: 10

        params do
          optional :state, type: String
        end

        get do
          conversations = params[:state] ? Conversation.where(state: params[:state]).order('updated_at desc') : Conversation.order("updated_at desc")
          max_page = (conversations.count / 10.to_f).ceil
          authorize! :read, Conversation
          present :max_page, max_page
          present :conversations, paginate(Kaminari.paginate_array(conversations)), with: Leo::Entities::ShortConversationEntity
        end

        desc "Return a conversation by id"
        get ':id' do
          conversation = Conversation.find(params[:id])
          authorize! :read, conversation
          present :conversation, conversation, with: Leo::Entities::ShortConversationEntity
        end
      end

      namespace 'staff/:staff_id/conversations' do
        before do
          authenticated
        end

        params do
          optional :state, type: String
        end

        desc "Return all relevant conversations of a user"
        get do
          if params[:state].try(:to_sym) == :escalated
            conversations = EscalationNote.includes(:conversation).where(escalated_to_id: params[:staff_id]).reduce([]) do |conversations, escalation_note|
              if escalation_note.active? && escalation_note.conversation.escalation_notes.order('created_at desc').first == escalation_note
                conversations << escalation_note.conversation
              end
              conversations
            end
          else
            conversations = User.find(params[:staff_id]).try(:conversations)
          end

          present :conversations, conversations, with: Leo::Entities::ShortConversationEntity
        end
      end

      namespace 'families/:family_id/conversation' do
        before do
          authenticated
        end

        desc "Return conversation associated with the family"
        get do
          family = Family.find(params[:family_id])
          present :conversation, family.conversation, with: Leo::Entities::ShortConversationEntity
        end
      end
    end
  end
end
