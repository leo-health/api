module Leo
  module V1
    class Conversations < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      rescue_from :all, :backtrace => true
      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter
      default_error_status 400

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
            if user.has_role :guardian
              
            end
            conversations = @user.conversations if @user
            authorize! :read, conversations
            present :conversation, conversations, with: Leo::Entities::ConversationEntity
          end

          route_param :id, type: Integer do
            desc "Retrieve a specific conversation"
            get do
              conversation = @user.conversations.try(:find, params[:id]) if @user
              authorize! :read, conversation
              present :conversation, conversation, with: Leo::Entities::ConversationWithMessagesEntity
            end
          end
        end
      end
    end
  end
end
