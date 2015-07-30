module Leo
  module V1
    class Passwords < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      rescue_from :all, :backtrace => true
      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter
      default_error_status 400

      resource :passwords do
        namespace :send_reset_email do
          params do
            requires :email, type: String
          end

          desc "send user reset password email"
          post do
            if user = User.find_by_email(params[:email].downcase)
              user.send_reset_password_instructions if user
            else
              error!({error_code: 422, error_message: "A user with this email does not exist"}, 422)
            end
          end
        end

        route_param :id do
          namespace :reset do
            params do
              requires :password, type: String
              requires :password_confirmation, type: String
            end

            desc "reset the password for user"
            put do
              if user = User.find_by_reset_password_token(params[:id]) and user.try(:reset_password_period_valid?)
                unless user.reset_password(params[:password], params[:password_confirmation])
                  error!({error_code: 422, error_message: "Password need to has at least 8 characters"}, 422)
                end
              else
                error!({error_code: 422, error_message: "Reset password period expired"}, 422)
              end
            end
          end
        end
      end
    end
  end
end
