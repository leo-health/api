module Leo
  module V1
    class UserConversations < Grape::API

      resource :user_conversations do
        before do
          authenticated
        end

        namespace 'escalate_conversation' do
          params do
            requires :escalated_to_id, type: Integer, allow_blank: false
            requires :conversation_id, type: Integer, allow_blank: false
            requires :priority, type: Integer, allow_blank: false
            optional :note, type: String
          end

          post do
            conversation = Conversation.find(params[:conversation_id])
            if conversation.status.to_sym == :closed
              error!({error_code: 422, error_message: "can't escalate closed conversation"}, 422)
            end

            user_conversation = conversation.user_conversations.find_or_create_by(user_id: params[:escalated_to_id]) do |user_conversation|
              user_conversation.escalated = true
            end

            if user_conversation.valid?
              user_conversation.escalation_notes.create(priority: params[:priority], note: params[:note])
            else
              error!({error_code: 422, error_message: user_conversation.errors.full_messages}, 422)
            end
          end
        end
      end
    end
  end
end
