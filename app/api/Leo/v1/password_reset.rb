module Leo
  module V1
    class PasswordReset < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      rescue_from :all, :backtrace => true
      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter
      default_error_status 400

      namespace :send_email do
        params do
          requires :email, type: String
        end

        desc "send user reset password email"
        post do
          if user = User.find_by_email(params[:email].downcase)
            user.send_reset_password_instructions if user
            present {message: "reset password instruction has been sent to your email"}
          else
            error!({error_code: 422, error_message: "Email is not correct"}, 422)
          end
        end
      end

      namespace :reset_password do
        params do
          requires :password, type: String
          requires :password_confirmation, type: Stirng
        end

        desc "reset the password for user"
        put do
          if user = User.find_by_reset_password_token(params[:token]) && user.try(:reset_password_period_valid?)
            user.reset_password!(params[:password], params[:password_confirmation])
          else
            error!({error_code: 422, error_message: "Error happened during reset password, or reset password period expired"}, 422)
          end
        end
      end
    end
  end
end
