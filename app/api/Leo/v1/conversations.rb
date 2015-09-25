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
          put do
            conversation = Conversation.find(params[:id])
            authorize! :update, conversation
            if conversation.close_conversation(current_user)
              present :conversation, conversation, with: Leo::Entities::ConversationEntity
              conversation.create_activity(:conversation_closed, owner: current_user)
              conversation.broadcast_status(current_user, :closed)
            else
              error!({error_code: 422, error_message: "can't close the conversation" }, 422)
            end
          end
        end

        desc 'escalate a conversation'
        namespace ':id/escalate' do
          params do
            requires :escalated_to_id, type: Integer, allow_blank: false
            requires :conversation_id, type: Integer, allow_blank: false
            requires :priority, type: Integer, allow_blank: false
            optional :note, type: String
          end

          put do
            conversation = Conversation.find(params[:id])
            authorize! :update, conversation
            escalation_note = conversation.escalate_conversation(escalated_by_id, escalated_to_id, note, priority)
            if escalation_note.try(:valid?)
              present :escalation_note, escalation_note
              conversation.create_activity(:conversation_escalated, owner: current_user)
              conversation.broadcast_status(current_user, :escalated)
            else
              error!({error_code: 422, error_message: "can't escalte the conversation" }, 422)
            end
          end
        end

        desc "Get all the conversations by status"
        params do
          optional :status, type: String, allow_blank: false
        end

        get do
          if params[:status]
            conversations = Conversation.where(status: params[:status]).order('updated_at desc')
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

      helpers do
        def broadcast_status(sender, new_status)
          channels = User.includes(:role).where.not(roles: {name: :guardian}).inject([]){|channels, user| channels << "newStatus#{user.email}"; channels}
          Pusher.trigger(channels, 'new_status', {new_status: new_status, conversation_id: id, changed_by: sender}) if channels.count > 0
        end
      end
    end
  end
end
