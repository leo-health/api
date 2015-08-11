module Leo
  module V1
    class Messages < Grape::API
      include Grape::Kaminari

      namespace 'conversations/:conversatoin_id' do
        resource :messages do
          before do
            authenticated
          end

          after_validation do
            unless @conversation = Conversation.find(params[:conversatoin_id])
              error!({error_code: 422, error_message: "The conversation does not exit."}, 422)
            end
          end

          desc "Return all messages for a conversation with pagination options"

          get do
            messages = @conversation.messages
            authorize! :read, Message
            present :messages, paginate(messages), with: Leo::Entities::MessageEntity
          end

          desc "Create a message"
          params do
            requires :body, type: String, allow_blank: false
            requires :message_type, type: String, allow_blank: false
          end

          post do
            message = @conversation.messages.new({body: params[:body], sender: current_user, message_type: params[:message_type]})
            if message.save
              authorize! :create, message
              present message, with: Leo::Entities::MessageEntity
            else
              error!({error_code: 422, error_message: message.errors.full_messages }, 422)
            end
          end

          route_param :message_id do
            before do
              unless @message = @conversation.messages.find(params[:message_id])
                error!({error_code: 422, error_message: "The message does not exist."})
              end
            end

            desc "update/escalate a message"
            params do
              requires :escalated_to_id, type: Integer, allow_blank: false
            end

            put do
              authorize! :update, @message
              if escalated_to = User.find(params[:escalate_to_id])
                @message.update_attributes(escalated_to: escalated_to)
              end
              present :message, @message, with: Leo::Entities::MessageEntity
            end
          end
        end
      end
    end
  end
end
