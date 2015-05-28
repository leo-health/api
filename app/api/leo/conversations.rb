module Leo
  module Entities
    class ConversationParticipantEntity < Grape::Entity
      expose :id
      expose :title
      expose :first_name
      expose :middle_initial
      expose :last_name
      expose :dob
      expose :sex
      expose :practice_id
      expose :family_id
      expose :primary_role
    end

    class MessageEntity < Grape::Entity
      expose :id
      expose :sender_id, documentation: {type: "integer", desc: "The Leo id of the sender." }
      expose :conversation_id,  documentation: {type: "integer", desc: "The conversation id." }
      expose :body, documentation: {type: "string", desc: "The message body." }
      expose :message_type, documentation: {type: "string", desc: "The message type." }
      expose :created_at, documentation: {type: "datetime", desc: "The date/time the message was created at." }
      expose :escalated_to, with: Leo::Entities::ConversationParticipantEntity, documentation: {type: "object", desc: "The physician who the message has been escalated to." }
      expose :escalated_by, with: Leo::Entities::ConversationParticipantEntity, documentation: {type: "object", desc: "The staff who the message has been escalated by." }
      expose :escalated_at, documentation: {type: "datetime", desc: "The date/time the message was escalated at." }
      expose :resolved_requested_at, documentation: {type: "datetime", desc: "The date/time a physician marked a message as resolved." }
      expose :resolved_approved_at, documentation: {type: "datetime", desc: "The date/time a staff member approved a resolved request." }
      expose :resolved, documentation: {type: "boolean", desc: "Has the escalation been resolved?" }
      expose :read_receipts
    end

    class ConversationEntity < Grape::Entity
      expose :id
      expose :participants, with: Leo::Entities::ConversationParticipantEntity
      expose :created_at
      expose :family
      expose :last_message_created
      expose :archived
      expose :archived_at
      expose :archived_by
    end

    class ConversationWithMessagesEntity < ConversationEntity
      expose :messages, with: Leo::Entities::MessageEntity
    end
  end
end
module Leo
  class Conversations < Grape::API
    version 'v1', using: :path, vendor: 'leo-health'
    format :json
    prefix :api

    rescue_from :all, :backtrace => true
    formatter :json, JSendSuccessFormatter
    error_formatter :json, JSendErrorFormatter
    default_error_status 400

    resource :conversations do 
      # Make sure no conversations can be accessed at all if user is not logged in
      before do 
        authenticated_user
      end

      desc "Return all relevant conversations for current user"
      # get "/conversations"
      get do
        present :conversation, Conversation.for_user(current_user), with: Leo::Entities::ConversationEntity
      end

      desc "Create a conversation for a given user"
      # post "/conversations"
      params do
        requires :user_id, type: Integer, desc: "User id"
        # requires :child_ids, type: Array[Integer], desc: "Ids of the children the conversation is about"
      end
      post do
        user_id = params[:user_id]
        if user_id != current_user.id
          error!({error_code: 403, error_message: "You don't have permission to create a conversation for this user."}, 403)
          return
        end

        user = User.find_by_id(user_id)
        if user.nil?
          error!({error_code: 422, error_message: "Could not create a conversation for the specified user. Make sure the user exists."}, 422)
        end

        # Create a conversation and add this user to it
        @conversation = Conversation.create!
        @conversation.family = user.family
        @conversation.participants << user.family.parents
        ## Add the children
        @conversation.save
        present :conversation, @conversation, with: Leo::Entities::ConversationEntity
      end

      route_param :conversation_id, type: Integer do 

        before do
          conversation_id = params[:conversation_id]
          @conversation = Conversation.find_by_id(conversation_id)
          puts "conversation_id: #{conversation_id}, conversation: #{@conversation}"
          if conversation_id.nil? or @conversation.nil?
            puts "nothing found"
            error!({error_code: 422, error_message: "The conversation was not found or you don't have permission to access it."}, 422)
            return
          end
        end

        desc "Retrieve a specific conversation"
        # get "/conversations/:conversation_id"
        get do 
          present :conversation, @conversation, with: Leo::Entities::ConversationWithMessagesEntity
        end

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

        resource :participants do
          desc "Add participant(s) to a conversation"
          params do
            requires :participant_ids, type: Array[Integer], desc: "Ids of the participants to be added to conversation"
          end
          post 'add' do 
            participant_ids = params[:participant_ids]

            # Ensure there is at least one participant id
            if participant_ids.nil? or participant_ids.count == 0
              error!({error_code: 422, error_message: "No valid participant id was provided"}, 422)
              return
            end

            # Ensure that all the participant ids are actual users that exist and that the current user has permission to add them
            participants = []
            participant_ids.each do |participant_id|
              participant = User.find_by_id(participant_id)
              if participant.nil?
                error!({error_code: 422, error_message: "An invalid participant id was provided"}, 422)
                return
              end
              # TODO: improve this check to make sure user has permissions to add participant
              participants << participant
            end
            participants.each do |participant|  
              @conversation.participants << participant unless @conversation.participants.include?(participant)
            end
            present @conversation, with: Leo::Entities::ConversationEntity
          end

          post 'remove' do 
            participant_ids = params[:participant_ids]

            # Ensure there is at least one participant id
            if participant_ids.nil? or participant_ids.count == 0
              error!({error_code: 422, error_message: "No valid participant id was provided"}, 422)
              return
            end

            # Ensure that all the participant ids are actual users that exist and that the current user has permission to add them
            participants = []
            participant_ids.each do |participant_id|
              participant = User.find_by_id(participant_id)
              if participant.nil? or @conversation.participants.include?(participant) == false
                error!({error_code: 422, error_message: "An invalid participant id was provided"}, 422)
                return
              end
              # TODO: improve this check to make sure user has permissions to add participant
              participants << participant
            end
            participants.each do |participant|  
              @conversation.participants.delete(participant)
            end
            present @conversation, with: Leo::Entities::ConversationEntity
          end
        end

        # resource :children do
        #   desc "Add child(s) to a conversation"
        #   params do
        #     requires :child_ids, type: Array[Integer], desc: "Ids of the children to be added to conversation"
        #   end
        #   post 'add' do 
        #     child_ids = params[:child_ids]

        #     # Ensure there is at least one child id
        #     if child_ids.nil? or child_ids.count == 0
        #       error!({error_code: 422, error_message: "No valid child id was provided"}, 422)
        #       return
        #     end

        #     # Ensure that all the child ids are actual users that exist and that the current user has permission to add them
        #     children = []
        #     child_ids.each do |child_id|
        #       child = User.find_by_id(child_id)
        #       if child.nil?
        #         error!({error_code: 422, error_message: "An invalid child id was provided"}, 422)
        #         return
        #       end
        #       # TODO: improve this check to make sure user has permissions to add child
        #       children << child
        #     end
        #     children.each do |child|  
        #       @conversation.children << child unless @conversation.children.include?(child)
        #     end
        #     present @conversation, with: Leo::Entities::ConversationEntity
        #   end

        #   post 'remove' do 
        #     child_ids = params[:child_ids]

        #     # Ensure there is at least one child id
        #     if child_ids.nil? or child_ids.count == 0
        #       error!({error_code: 422, error_message: "No valid child id was provided"}, 422)
        #       return
        #     end

        #     # Ensure that all the child ids are actual users that exist and that the current user has permission to add them
        #     children = []
        #     child_ids.each do |child_id|
        #       child = User.find_by_id(child_id)
        #       if child.nil? or @conversation.children.include?(child) == false
        #         error!({error_code: 422, error_message: "An invalid child id was provided"}, 422)
        #         return
        #       end
        #       # TODO: improve this check to make sure user has permissions to add child
        #       children << child
        #     end
        #     children.each do |child|  
        #       @conversation.children.delete(child)
        #     end
        #     present @conversation, with: Leo::Entities::ConversationEntity
        #   end
        # end


      end
    end
  end
end
