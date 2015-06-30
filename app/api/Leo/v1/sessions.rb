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
        end

        desc "create a session when user login"
        post do
          user = User.find_by_email(params[:email].downcase)
          unless user && user.valid_password?(password) && (user.has_role? :child)
            error!({error_code: 422, error_message: "Invalid Email or Password."}, 422)
            return
          end
          if session = user.sessions.create
            present	session
          end
        end
      end

      namespace :logout do
        params do
          requires :user_id, type: Integer, allow_blank: false
          requires :access_token, type: String, allow_blank: false
        end

        desc "destroy the session when user logout"
        delete do
          session = current_user.sessions.find_by_authentication_token(params[:access_token])
          session.try(:update_attributes, disabled_at: Time.now)
        end
      end
    end
  end
end


