module Leo
  module V1
    class Messages < Grape::API
      include Grape::Kaminari

      namespace 'conversations/:conversation_id' do
        paginate per_page: 25

        resource :messages do
          before do
            authenticated
          end

          after_validation do
            @conversation = Conversation.find(params[:conversation_id])
          end

          namespace 'full' do
            get do
              messages = @conversation.messages
              authorize! :read, Message
              system_messages = PublicActivity::Activity.where(key: "conversation.conversation_closed", trackable_id: @conversation.id)
              full_messages =(system_messages + messages).sort{|x, y|y.created_at <=> x.created_at}
              full_messages.map! do |message|
                case message.class.name
                when 'PublicActivity::Activity'
                  {system_message: message}
                when 'Message'
                  {regular_message: message}
                end
              end
              present :conversation_id, @conversation.id
              present :messages, paginate(Kaminari.paginate_array(full_messages)), with: Leo::Entities::FullMessageEntity
            end
          end

          desc "Return all messages for a conversation with pagination options"
          get do
            messages = @conversation.messages.order('created_at DESC')
            authorize! :read, Message
            present paginate(messages), with: Leo::Entities::MessageEntity
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
              message.broadcast_message(current_user)
              if conversation_status.to_sym == :closed
                @conversation.create_activity(:conversation_opened, owner: current_user )
                @conversation.broadcast_status(current_user, :open)
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
    end
  end
end
