module Leo
  module Entities
    class MessageEntity < Grape::Entity
      expose :id
      expose :sender_id, documentation: {type: "integer", desc: "The Leo id of the sender." }
      expose :conversation_id,  documentation: {type: "integer", desc: "The conversation id." }
      expose :body, documentation: {type: "string", desc: "The message body." }
      expose :message_type, documentation: {type: "string", desc: "The message type" }
      expose :created_at
    end
    class ConversationParticipantEntity < Grape::Entity 
    end

    class ConversationEntity < Grape::Entity
      expose :id
      expose :participants
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
        present Conversation.for_user(current_user), with: Leo::Entities::ConversationEntity
      end

      desc "Create a conversation for a given user"
      params do
        requires :user_id, type: Integer, desc: "User id"
        requires :child_ids, type: Array[Integer], desc: "Ids of the children the conversation is about"
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

        children = []
        params[:child_ids].each do |child_id|
          child = User.find_by_id(child_id)
          if child.nil? or child.family_id != user.family_id
            error!({error_code: 403, error_message: "You don't have permission to create a conversation with 1 or more of the children provided."}, 403)
            return
          end
          children << child
        end

        # Create a conversation and add this user to it
        conversation = Conversation.create!
        conversation.participants << user
        ## Add the children
        conversation.children << children
        conversation.save
        present conversation, with: Leo::Entities::ConversationEntity
      end
    end

    route_param :conversation_id, type: Array do 

      before do
        conversation_id = params[:conversation_id]
        conversation = Conversation.find_by_id(conversation_id)
        if conversation_id.nil? or conversation.nil?
          error!({error_code: 422, error_message: "The conversation was not found or you don't have permission to access it."}, 422)
          return
        end
      end
      resource :messages do 

        desc "Return all messages for current conversation"
        # get "/messages"
        get do
          # TODO: Check authorization
          present conversation.messages, with: Leo::Entities::MessageEntity
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
          if body.nil? or body.strip!.length == 0
            error({error_code: 422, error_message: "The message body can not be empty."}, 422)
            return
          end
          message = Conversation.messages.create(sender_id: sender_id, body: body)
          present message, with: Leo::Entities::MessageEntity
        end

        desc "Return a message"
        # get "/messages/{id}"
        params do 
          requires :id, type: Integer, desc: "User id"
        end
        route_param :id do 
          get do
            # TODO: Check authorization
            # TODO: Check valid id
            present converation.messages.where(id: message_id).first
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
            conversation.participants << participant unless conversation.participants.include?(participant)
          end
          present conversation, with: Leo::Entities::ConversationEntity
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
            if participant.nil? or conversation.participants.include?(participant) == false
              error!({error_code: 422, error_message: "An invalid participant id was provided"}, 422)
              return
            end
            # TODO: improve this check to make sure user has permissions to add participant
            participants << participant
          end
          participants.each do |participant|  
            conversation.participants.delete(participant)
          end
          present conversation, with: Leo::Entities::ConversationEntity
        end
      end

      resource :children do
        desc "Add child(s) to a conversation"
        params do
          requires :child_ids, type: Array[Integer], desc: "Ids of the children to be added to conversation"
        end
        post 'add' do 
          child_ids = params[:child_ids]

          # Ensure there is at least one child id
          if child_ids.nil? or child_ids.count == 0
            error!({error_code: 422, error_message: "No valid child id was provided"}, 422)
            return
          end

          # Ensure that all the child ids are actual users that exist and that the current user has permission to add them
          children = []
          child_ids.each do |child_id|
            child = User.find_by_id(child_id)
            if child.nil?
              error!({error_code: 422, error_message: "An invalid child id was provided"}, 422)
              return
            end
            # TODO: improve this check to make sure user has permissions to add child
            children << child
          end
          children.each do |child|  
            conversation.children << child unless conversation.children.include?(child)
          end
          present conversation, with: Leo::Entities::ConversationEntity
        end

        post 'remove' do 
          child_ids = params[:child_ids]

          # Ensure there is at least one child id
          if child_ids.nil? or child_ids.count == 0
            error!({error_code: 422, error_message: "No valid child id was provided"}, 422)
            return
          end

          # Ensure that all the child ids are actual users that exist and that the current user has permission to add them
          children = []
          child_ids.each do |child_id|
            child = User.find_by_id(child_id)
            if child.nil? or conversation.children.include?(child) == false
              error!({error_code: 422, error_message: "An invalid child id was provided"}, 422)
              return
            end
            # TODO: improve this check to make sure user has permissions to add child
            children << child
          end
          children.each do |child|  
            conversation.children.delete(child)
          end
          present conversation, with: Leo::Entities::ConversationEntity
        end
      end
    end
  end
end
