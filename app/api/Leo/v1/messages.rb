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
          present message, with: Leo::Entities::MessageEntity
        end
      end

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
              close_conversation_notes = @conversation.closure_notes
              escalation_notes = EscalationNote.includes(:user_conversation).where(user_conversation: { conversation_id: @conversation.id })
              full_messages =(messages + close_conversation_notes + escalation_notes).sort{ |x, y|y.created_at <=> x.created_at }
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
            requires :type_name, type: String, allow_blank: false, values: ['text', 'image']
          end

          post do
            message_params = { sender: current_user,
                               type_name: params[:type_name] }

            if params[:type_name] == 'image'
              byebug
              message_params.merge!(message_photo_attributes: { image: image_decoder(params[:body]) })
            else
              message_params.merge!(body: params[:body])
            end
            byebug
            message = @conversation.messages.new(message_params)
            authorize! :create, message
            if message.save
              present message, with: Leo::Entities::MessageEntity
              message.broadcast_message(current_user)
            else
              error!({ error_code: 422, error_message: message.errors.full_messages }, 422)
            end
          end
        end

        helpers do
          def image_decoder(image)
            data = StringIO.new(Base64.decode64(image))
            data.class.class_eval { attr_accessor :original_filename, :content_type }
            data.content_type = "image/png"
            data.original_filename = "uploaded_message_photo.png"
            data
          end
        end
      end
    end
  end
end
