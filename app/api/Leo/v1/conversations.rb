module Leo
  module V1
    class Conversations < Grape::API
      include Grape::Kaminari

      resource :conversations do
        before do
          authenticated
        end

        desc "Close a conversation"
        put ":id" do
          conversation = Conversation.find(params[:id])
          authorize! :read, conversation
          if conversation.update_attributes(status: "closed")
            present :conversation, conversation, with: Leo::Entities::ConversationEntity
          end
        end

        desc "Get all the conversations with selecting option: status"
        params do
          optional :status, type: String, allow_blank: false
        end

        get do

          authorize! :read, Conversation
          conversations = Conversation.all.order('updated_at DESC')
          present :conversations, paginate(Conversation.all), with: Leo::Entities::ConversationEntity
        end
      end

      namespace 'users/:user_id/conversations' do
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
            authorize! :read, conversations
            present :conversation, conversations, with: Leo::Entities::ConversationEntity
          else
            conversations = @user.conversations if @user
            authorize! :read, Conversation
            present :conversations, paginate(conversations), with: Leo::Entities::ConversationEntity
          end
        end
      end
    end
  end
end
