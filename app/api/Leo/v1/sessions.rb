module Leo
  module V1
    class Sessions < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      rescue_from :all, :backtrace => true
      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter
      default_error_status 400


      namespace :login do
        params do
          requires :email, type: String, allow_blank: false
          requires :password, type: String, allow_blank: false
          optional :device_token, type: String
        end

        desc "create a session when user login"
        post do
          user = User.find_by_email(params[:email].downcase)
          unless user && user.valid_password?(params[:password])
            error!({error_code: 403, error_message: "Invalid Email or Password."}, 422)
          end
          session = user.sessions.create(device_token: params[:device_token])
          if session.valid?
            present :user, user, with: Leo::Entities::UserEntity
            present :session, session, with: Leo::Entities::SessionEntity
          else
            error!({error_code: 422, error_message: session.errors.full_messages }, 422)
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
    end
  end
end
