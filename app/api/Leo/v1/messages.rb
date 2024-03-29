module Leo
  module V1
    class Messages < Grape::API
      include Grape::Kaminari
      desc 'Return a single message'
      namespace 'messages' do
        before do
          authenticated
        end

        get ':id' do
          message = Message.find(params[:id])
          authorize! :read, Message
          present message, with: Leo::Entities::MessageEntity, device_type: session_device_type
        end
      end

      namespace 'conversations/:conversation_id' do
        paginate per_page: MESSAGE_PAGE_SIZE

        resource :messages do
          before do
            authenticated
          end

          params do
            optional :start_datetime, type: DateTime, desc: "Start datetime", allow_blank: false
            optional :end_datetime, type: DateTime, desc: "End datetime", allow_blank: false
          end

          after_validation do
            @conversation = Conversation.find(params[:conversation_id])
          end

          namespace 'full' do
            get do
              messages = @conversation.messages
              authorize! :read, Message
              close_conversation_notes = @conversation.closure_notes
              escalation_notes = @conversation.escalation_notes
              full_messages =(messages + close_conversation_notes + escalation_notes).sort{ |x, y|y.created_at <=> x.created_at }
              present :conversation_id, @conversation.id
              present :init_message_id, @conversation.messages.first.id
              present :messages, paginate(Kaminari.paginate_array(full_messages)), with: Leo::Entities::FullMessageEntity, device_type: session_device_type
            end
          end

          desc "Return all messages for a conversation with pagination options"
          get do
            messages = @conversation.messages.order('created_at DESC')

            if params[:start_datetime]
              start_datetime = Time.zone.parse(params[:start_datetime])
              messages = messages.where("created_at > ?", start_datetime)
              message_to_truncate = messages.last
              if message_to_truncate
                truncated_date = message_to_truncate.created_at.iso8601.to_datetime
                if truncated_date <= start_datetime
                  messages = messages.where.not id:messages.last.id
                end
              end
            end

            if params[:end_datetime]
              end_datetime = Time.zone.parse(params[:end_datetime])
              messages = messages.where("created_at < ?", end_datetime)
            end

            authorize! :read, Message
            present paginate(messages), with: Leo::Entities::MessageEntity, device_type: session_device_type
          end

          desc "Create a message"
          params do
            requires :body, type: String, allow_blank: false
            requires :type_name, type: String, allow_blank: false, values: ['text', 'image']
          end

          post do
            message_params = { sender: current_user,
                               type_name: params[:type_name] }

            if params[:type_name] == 'image'
              message_params.merge!(message_photo_attributes: { image: image_decoder(params[:body]) })
            else
              message_params.merge!(body: params[:body])
            end
            message = @conversation.messages.new(message_params)
            authorize! :create, message
            if message.save
              present message, with: Leo::Entities::MessageEntity, device_type: session_device_type
              message.broadcast_message(current_user)
            else
              error!({ error_code: 422, user_message: message.errors.full_messages.first }, 422)
            end
          end
        end
      end
    end
  end
end
