module Leo
  module V1
    class Conversations < Grape::API
      namespace 'users/:user_id' do
        resource :conversations do
          before do
            authenticated
          end

          after_validation do
            @user = User.find(params[:user_id])
          end

          desc "Return all relevant conversations of a user"
          get do
            if @user && @user.has_role?(:guardian)
              conversations = Conversation.find_by_family_id(@user.family_id)
            else
              conversations = @user.conversations if @user
            end
            authorize! :read, conversations
            present :conversation, conversations, with: Leo::Entities::ConversationEntity
          end
        end
      end
    end
  end
end
