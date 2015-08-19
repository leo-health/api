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

        desc "Get all the conversations by status"
        params do
          optional :status, type: String, allow_blank: false
        end

        get do
          if params[:status]
            conversations = Conversation.where(status: params[:status]).order('updated_at desc')
          else
            conversations = %i(open escalated closed).inject([]) do |conversations, status|
              conversations << Conversation.where(status: status).order('updated_at desc')
              conversations.flatten
            end
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
          optional :status, type: String, allow_blank: false, values: ["escalated", "read", "new"]
        end

        desc "Return all relevant conversations of a user"
        get do
          if @user && @user.has_role?(:guardian)
            conversations = Conversation.find_by_family_id(@user.family_id)
            authorize! :read, conversations
            present :conversation, conversations, with: Leo::Entities::ConversationEntity
          else
            if params[:status]
              case params[:status]
              when :escalated
                @user.escalated_conversations.where()
              when :new
                @user.unread_conversations
              end
            else
              conversations = @user.conversations if @user
            end
            authorize! :read, Conversation
            present :conversations, paginate(conversations), with: Leo::Entities::ConversationEntity
          end
        end
      end
    end
  end
end
