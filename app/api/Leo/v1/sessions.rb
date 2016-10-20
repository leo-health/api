module Leo
  module V1
    class Sessions < Grape::API
      resource :sessions do
        params do
          requires :authentication_token, type: String, allow_blank: false
          optional :device_type, type: String
          optional :device_token, type: String
          optional :os_version, type: String
          optional :platform, type: String
          optional :client_version, type: String
        end

        desc 'creates new session without logging the user out. Deletes the existing session if successful'
        post do
          unless existing_session = Session.find_by(authentication_token: params[:authentication_token])
            error!('401 Unauthorized', 401)
          end

          user = existing_session.user
          session_params = params.slice(:device_token, :device_type, :os_version, :platform, :client_version, :authentication_token)

          begin
            Session.transaction do
              existing_session.try(:destroy)
              next_session = user.sessions.create!(session_params)
              present :user, user, with: Leo::Entities::UserEntity
              present :session, next_session, with: Leo::Entities::SessionEntity
            end
          rescue ActiveRecord::RecordInvalid => invalid
            error!({error_code: 422, user_message: invalid.record.errors.full_messages.first }, 422)
          end
        end
      end

      namespace :login do
        params do
          requires :email, type: String, allow_blank: false
          requires :password, type: String, allow_blank: false
          optional :platform, type: String
          optional :device_type, type: String
          optional :device_token, type: String
          optional :os_version, type: String
          optional :client_version, type: String
        end

        desc "create a session when user login"
        post do

          Rails.logger.info("POST /sessions/login #{params}")

          
          user = User.complete.find_by_email(params[:email].downcase)
          unless user && user.has_role?(:guardian) && user.valid_password?(params[:password])
            error!({error_code: 403, user_message: "Invalid Email or Password."}, 422)
          end

          # destroy stale sessions for the same device - in case users log out while offline
          if params[:platform].try(:to_sym) == :ios && params[:device_token]
            Session.where(params.slice(:device_token, :platform)).destroy_all
          end

          session_params = params.slice(:device_token, :device_type, :os_version, :platform, :client_version)
          session = user.sessions.create(session_params)

          if session.valid?
            present :user, user, with: Leo::Entities::UserEntity
            present :session, session, with: Leo::Entities::SessionEntity
          else
            error!({error_code: 422, user_message: session.errors.full_messages.first }, 422)
          end
        end
      end

      namespace :logout do
        params do
          requires :authentication_token, type: String, allow_blank: false
        end

        desc "destroy the session when user logout"
        delete do
          session = Session.find_by_authentication_token(params[:authentication_token])
          session.try(:destroy)
        end
      end

      namespace :provider_login do
        params do
          requires :email, type: String, allow_blank: false
          requires :password, type: String, allow_blank: false
          optional :platform, type: String
          optional :device_type, type: String
          optional :os_version, type: String
        end

        post do
          user = User.find_by_email(params[:email].downcase)
          unless user && !user.has_role?(:guardian) && user.valid_password?(params[:password])
            error!({error_code: 403, user_message: "Invalid Email or Password."}, 422)
          end

          session = user.sessions.create(params.slice(:device_type, :os_version, :platform))
          if session.valid?
            present :user, user, with: Leo::Entities::UserEntity
            present :session, session, with: Leo::Entities::SessionEntity
          else
            error!({error_code: 422, user_message: session.errors.full_messages.first }, 422)
          end
        end
      end

      namespace :staff_validation do
        params do
          requires :authentication_token, type: String
        end

        get do
          if session = Session.find_by(authentication_token: params[:authentication_token])
            authorize! :read, session
          else
            error!('401 Unauthorized', 401)
          end
        end
      end
    end
  end
end
