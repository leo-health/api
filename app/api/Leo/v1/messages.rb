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
            end
            desc "return a message"
            get do
              authorize! @message
              present :message, @message, with: Leo::Entities::MessageEntity
            end

            desc "update a message"
            params do

            end
            put do

            end

            desc "Escalate a message"
            params do
              requires :escalate_to_id, type: Integer, desc: "Id for the user who the message is being escalated to"
            end
            post "escalate" do
              escalate_to_id = params[:escalate_to_id]
              escalated_to = User.find_by_id(escalate_to_id)
              if escalate_to_id.nil? or escalated_to.nil?
                error({error_code: 422, error_message: "The user you are trying to escalate to is invalid"})
                return
              end
              @message.escalated_to = escalated_to
              @message.escalated_by = current_user
              @message.escalated_at = DateTime.now
              @message.save

              present :message, @message, with: Leo::Entities::MessageEntity
            end



            desc "Request message marked as closed"
            params do
            end
            post "request_closed" do
              if current_user.id != @message.escalate_to_id
                error({error_code: 403, error_message: "You are not allowed to request this message to be marked as closed."})
                return
              end
              @message.resolved_requested_at = DateTime.now
              @message.save
              present :message, @message, with: Leo::Entities::MessageEntity
            end

            desc "Approve a request to mark message as closed"
            params do
            end
            post "approve_closed" do
              if current_user.id != @message.escalate_by_id
                error({error_code: 403, error_message: "You are not allowed to approve a request to mark this message as closed."})
                return
              end
              @message.resolved_approved_at = DateTime.now
              @message.save
              present :message, @message, with: Leo::Entities::MessageEntity
            end
          end
        end
      end
    end
  end
end
