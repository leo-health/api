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
              present :conversation_id, conversation.id
              present :created_by, current_user
              present :note, params[:note]
              present :message_type, 'ClosureNote'
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
              present :escalated_to, escalated_to
              present :note, params[:note]
              present :conversation_id, conversation.id
              present :created_by, current_user
              present :message_type, 'EscalationNote'
            else
              error!({error_code: 422, error_message: "can't escalte the conversation" }, 422)
            end
          end
        end

        desc "Get all the conversations by state"
        params do
          optional :state, type: String, allow_blank: false
        end

        get do
          if params[:state]
            conversations = Conversation.where(state: params[:state]).order('updated_at desc')
          else
            conversations = Conversation.sort_conversations
          end
          authorize! :read, Conversation
          present :conversations, paginate(Kaminari.paginate_array(conversations)), with: Leo::Entities::ConversationEntity
        end
      end

      namespace 'users/:user_id/conversations' do
        before do
          authenticated
        end

        after_validation do
          @user = User.find(params[:user_id])
        end

        params do
          optional :state, type: String, allow_blank: false, values: ["escalated", "new"]
        end

        desc "Return all relevant conversations of a user"
        get do
          if @user.has_role?(:guardian)
            conversation = Conversation.find_by_family_id(@user.family_id)
            authorize! :read, conversation
            present :conversation, conversation, with: Leo::Entities::ConversationEntity and return
          else
            if params[:state] && params[:state] == "escalated"
              conversations = @user.escalated_conversations
            elsif params[:state] && params[:state] == "new"
              conversations = @user.unread_conversations
            end
            authorize! :read, Conversation
            present :conversations, paginate(conversations), with: Leo::Entities::ConversationEntity
          end
        end
      end
    end
  end
end
