module Leo
  module V1
    class Sessions < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      namespace :login do
        params do
          requires :email, type: String, allow_blank: false
          requires :password, type: String, allow_blank: false
          optional :platform, type: String,  values: ['web', 'ios', 'android']
          optional :device_type, type: String
          optional :device_token, type: String
          optional :os_version, type: String
        end

        desc "create a session when user login"
        post do
          user = User.complete.find_by_email(params[:email].downcase)
          unless user && user.has_role?(:guardian) && user.valid_password?(params[:password])
            error!({error_code: 403, user_message: "Invalid Email or Password."}, 422)
          end

          session_params = params.slice(:device_token, :device_type, :os_version, :platform)
          
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
        end

        post do
          user = User.find_by_email(params[:email].downcase)
          unless user && !user.has_role?(:guardian) && user.valid_password?(params[:password])
            error!({error_code: 403, user_message: "Invalid Email or Password."}, 422)
          end

          session = user.sessions.create
          if session.valid?
            present :user, user, with: Leo::Entities::UserEntity
            present :session, session, with: Leo::Entities::SessionEntity
          else
            error!({error_code: 422, user_message: session.errors.full_messages.first }, 422)
          end
        end
      end
    end
  end
end
