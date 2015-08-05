module Leo
  module V1
    class Conversations < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      rescue_from :all, :backtrace => true
      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter
      default_error_status 400

      namespace 'users/:user_id' do
        resource :conversations do
          before do
            byebug
            authenticated
          end

          after_validation do
            byebug
            @user = User.find(params[:user_id])
          end

          desc "Return all relevant conversations of a user"
          get do
            byebug
            user = User.find()
            # conversations =
            present :conversation, Conversation.for_user(current_user), with: Leo::Entities::ConversationEntity
          end

          route_param :id, type: Integer do
            desc "Retrieve a specific conversation"
            get do
              conversation_id = params[:conversation_id]
              @conversation = Conversation.find_by_id(conversation_id)
              if conversation_id.nil? or @conversation.nil?
                puts "nothing found"
                error!({error_code: 422, error_message: "The conversation was not found or you don't have permission to access it."}, 422)
                return
              end
              present :conversation, @conversation, with: Leo::Entities::ConversationWithMessagesEntity
            end
          end

          desc "Create a conversation for a user"
          params do
            requires :user_id, type: Integer, desc: "User id"
          end

          post do
            @conversation = Conversation.create!
            @conversation.family = user.family
            @conversation.participants << user.family.parents
            ## Add the children
            @conversation.save
            present :conversation, @conversation, with: Leo::Entities::ConversationEntity
          end
        end
      end
    end
  end
end



# resource :participants do
#   desc "Add participant(s) to a conversation"
#   params do
#     requires :participant_ids, type: Array[Integer], desc: "Ids of the participants to be added to conversation"
#   end
#   post 'add' do
#     participant_ids = params[:participant_ids]
#
#     # Ensure there is at least one participant id
#     if participant_ids.nil? or participant_ids.count == 0
#       error!({error_code: 422, error_message: "No valid participant id was provided"}, 422)
#       return
#     end
#
#     # Ensure that all the participant ids are actual users that exist and that the current user has permission to add them
#     participants = []
#     participant_ids.each do |participant_id|
#       participant = User.find_by_id(participant_id)
#       if participant.nil?
#         error!({error_code: 422, error_message: "An invalid participant id was provided"}, 422)
#         return
#       end
#       # TODO: improve this check to make sure user has permissions to add participant
#       participants << participant
#     end
#     participants.each do |participant|
#       @conversation.participants << participant unless @conversation.participants.include?(participant)
#     end
#     present @conversation, with: Leo::Entities::ConversationEntity
#   end
#
#   post 'remove' do
#     participant_ids = params[:participant_ids]
#
#     # Ensure there is at least one participant id
#     if participant_ids.nil? or participant_ids.count == 0
#       error!({error_code: 422, error_message: "No valid participant id was provided"}, 422)
#       return
#     end
#
#     # Ensure that all the participant ids are actual users that exist and that the current user has permission to add them
#     participants = []
#     participant_ids.each do |participant_id|
#       participant = User.find_by_id(participant_id)
#       if participant.nil? or @conversation.participants.include?(participant) == false
#         error!({error_code: 422, error_message: "An invalid participant id was provided"}, 422)
#         return
#       end
#       # TODO: improve this check to make sure user has permissions to add participant
#       participants << participant
#     end
#     participants.each do |participant|
#       @conversation.participants.delete(participant)
#     end
#     present @conversation, with: Leo::Entities::ConversationEntity
#   end
# end



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
