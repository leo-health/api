module Leo
  module V1
    class UserConversations < Grape::API

      resource :user_conversations do
        before do
          authenticated
        end

        namespace "set_priority" do
          params do
            requires :priority, type: Integer, values: [0, 1]
            requires :conversation_id, type: Integer, allow_blank: false
            requires :user_id, type: Integer, allow_blank: false
          end

          put do
            user_conversation = UserConversation.find_by(conversation_id: params[:conversation_id], user_id: params[:user_id])
            if user_conversation
              authorize! :update, user_conversation
              user_conversation.update_attributes(priority: params[:priority])
              present :user_conversation, user_conversation
            else
              error!({error_code: 422, error_message: "Can't find user_conversation record"}, 422)
            end
          end
        end
      end
    end
  end
end
