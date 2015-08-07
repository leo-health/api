module Leo
  module V1
    class Messages < Grape::API
      resource :messages do
        desc "Return all messages for current conversation"
        # get "/messages"
        params do
          optional :escalated,  type:   Boolean, desc: "Filter by messages that are escalated or not"
        end
        get do
          messages = @conversation.messages
          unless params[:escalated].nil?
            if params[:escalated] == true
              messages = messages.where.not(escalated_to: nil)
            else
              messages = messages.where(escalated_to: nil)
            end
          end
          # TODO: Check authorization
          present :count, messages.count
          present :messages, messages, with: Leo::Entities::MessageEntity

        end

        desc "Create a message"
        params do
          requires :sender_id, type: Integer, desc: "Id for the message sender"
          requires :body, type: String, desc: "Message contents"
        end
        post do
          sender_id = params[:sender_id]
          sender = User.find_by_id(sender_id)
          if sender_id.nil? or sender.nil? or sender_id != current_user.id
            error({error_code: 422, error_message: "The sender does not exist or you don't have permission to create a message for that sender"}, 422)
            return
          end

          body = params[:body]
          puts "The body says: #{body}, and when stripped says: #{body.strip!}"
          if body.nil? or body.length == 0
            error({error_code: 422, error_message: "The message body can not be empty."}, 422)
            return
          end
          message = @conversation.messages.create(sender_id: sender_id, body: body)
          present message, with: Leo::Entities::MessageEntity
        end

        desc "Operate on individual messages"
        route_param :message_id do
          before do
            id = params[:message_id]
            # TODO: Check authorization
            @message = @conversation.messages.where(id: id).first
            if id.nil? or @message.nil?
              error({error_code: 404, error_message: "The message you requested does not exist."})
              return
            end
          end
          desc "Return a message"
          # get "/messages/{id}"
          get do
            # TODO: Check authorization
            present :message, @message, with: Leo::Entities::MessageEntity
          end

          desc "Escalate a message"
          # post "/messages/{id}/escalate"
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

          desc "Request message marked as resolved"
          params do
          end
          post "request_resolved" do
            if current_user.id != @message.escalate_to_id
              error({error_code: 403, error_message: "You are not allowed to request this message to be marked as resolved."})
              return
            end
            @message.resolved_requested_at = DateTime.now
            @message.save
            present :message, @message, with: Leo::Entities::MessageEntity
          end

          desc "Approve a request to mark message as resolved"
          params do
          end
          post "approve_resolved" do
            if current_user.id != @message.escalate_by_id
              error({error_code: 403, error_message: "You are not allowed to approve a request to mark this message as resolved."})
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
