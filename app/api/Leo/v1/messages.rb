module Leo
  module V1
    class Messages < Grape::API
      include Grape::Kaminari

      namespace 'conversations/:conversation_id' do
        resource :messages do
          before do
            authenticated
          end

          after_validation do
            @conversation = Conversation.find(params[:conversation_id])
          end

          paginate per_page: 25

          desc "Return all messages for a conversation with pagination options"
          get do
            messages = @conversation.messages
            authorize! :read, Message
            present :messages, paginate(messages), with: Leo::Entities::MessageEntity
          end

          desc "Create a message"
          params do
            requires :body, type: String, allow_blank: false
            requires :type_name, type: String, allow_blank: false
          end

          post do
            conversation_status = @conversation.status
            message = @conversation.messages.new({body: params[:body], sender: current_user, type_name: params[:type_name]})
            authorize! :create, message
            if message.save
              present message, with: Leo::Entities::MessageEntity
              broadcast_message(message)
              if conversation_status == :closed
                @conversation.create_activity(:conversation_opened, owner: current_user )
                broadcast_status(@conversation)
              end
            else
              error!({error_code: 422, error_message: message.errors.full_messages }, 422)
            end
          end

          desc "update/escalate a message"
          params do
            requires :escalated_to_id, type: Integer, allow_blank: false
          end

          put ':id' do
            message = @conversation.messages.find(params[:id])
            authorize! :update, message
            escalated_to = User.find(params[:escalated_to_id])
            if message.escalate(escalated_to, current_user)
              present :message, message, with: Leo::Entities::MessageEntity
            end
          end
        end
      end

      helpers do
        def broadcast_message(message)
          message_params = message.as_json(include: :sender).to_json
          conversation = message.conversation
          participants = (conversation.staff + conversation.family.guardians)
          participants.delete(current_user)
          if participants.count > 0
            channels = participants.inject([]){|channels, user| channels << "newMessage#{user.email}"; channels}
            Pusher.trigger(channels, 'new_message', message_params)
          end
        end

        def broadcast_status(conversation)
          channels = User.includes(:role).where.not(roles: {name: :guardian}).inject([]){|channels, user| channels << "newStatus#{user.email}"; channels}
          Pusher.trigger(channels, 'new_status', {new_status: :open, conversation_id: conversation.id, closed_by: current_user}) if channels.count > 0
        end
      end
    end
  end
end
