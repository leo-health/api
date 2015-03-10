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
				c = Conversation.create!
				c.participants << user
				c.save
				return c
			end

		end

		route_param :conversation_id do 
			resource :messages do 

				desc "Return all messages for current conversation"
				# get "/messages"
				get do
					# TODO: Check authorization
					present Conversation.find(conversation_id).messages, with: Leo::Entities::MessageEntity
				end

				desc "Return an message"
				# get "/messages/{id}"
				params do 
					requires :id, type: Integer, desc: "User id"
				end
				route_param :id do 
					get do
						# TODO: Check authorization
						# TODO: Check valid id
						present Message.find(message_id)
					end
				end
			end
		end
	end
end
