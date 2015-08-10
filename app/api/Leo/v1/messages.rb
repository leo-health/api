module Leo
  module V1
    class Messages < Grape::API
      namespace 'conversations/:conversatoin_id' do
        resource :messages do
          before do
            authenticated
          end

          after_validation do
            unless @conversation = Conversation.find(params[:conversation_id])
              error!({error_code: 422, error_message: "The conversation does not exit."}, 422)
            end
          end

          desc "Return all messages for a conversation"
          params do
            optional :escalated,  type: Boolean, desc: "Filter by messages that are escalated or not"
          end
          get do
            messages = @conversation.messages
            if params[:escalated]
              messages = messages.where.not(escalated_to_id: nil)
            else
              messages = messages.where(escalated_to_id: nil)
            end
            authorize! :read, Message
            present :messages, messages, with: Leo::Entities::MessageEntity
          end

          desc "Create a message"
          params do
            requires :body, type: String, allow_blank: false
            requires :type, type: String, allow_blank: false
          end

          post do
            if message = @conversation.messages.create({body: params[:body], sender: current_user, type: params[:type]})
              authorize! message
              present message, with: Leo::Entities::MessageEntity
            end
          end

          route_param :message_id do
            before do
              unless @message = @conversation.messages.find(params[:message_id])
                error!({error_code: 422, error_message: "The message does not exist."})
              end
              authorize! @message
            end

            desc "return a message"
            get do
              present :message, @message, with: Leo::Entities::MessageEntity
            end

            desc "update/escalate a message"
            params do
              requires :escalated_to_id, type: Integer, allow_blank: false
            end

            put do
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
