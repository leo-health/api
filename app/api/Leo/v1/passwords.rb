module Leo
  module V1
    class Passwords < Grape::API
      resource :passwords do
        namespace :send_reset_email do
          params do
            requires :email, type: String
          end

          desc "send user reset password email"
          post do
            if user = User.find_by_email(params[:email].downcase)
              user.send_reset_password_instructions
            else
              error!({error_code: 422, error_message: "Invalid Email."}, 422)
            end
          end
        end

        namespace :change_password do
          before do
            authenticated
          end

          params do
            requires :current_password, type: String
            requires :password, type: String
            requires :password_confirmation, type: String
          end

          put do
            unless current_user.valid_password?(params[:current_password])
              error!({error_code: 422, error_message: "Current password is not valid."}, 422)
            end
            unless current_user.reset_password(params[:password], params[:password_confirmation])
              error!({error_code: 422, error_message: "Password need to has at least 8 characters."}, 422)
            end
          end
        end

        route_param :token do
          namespace :reset do
            params do
              requires :password, type: String
              requires :password_confirmation, type: String
            end

            desc "reset the password for user"
            put do
              if user = User.with_reset_password_token(params[:token]) and user.try(:reset_password_period_valid?)
                unless user.reset_password(params[:password], params[:password_confirmation])
                  error!({error_code: 422, error_message: "Password need to has at least 8 characters."}, 422)
                end
              else
                error!({error_code: 422, error_message: "Reset password period expired."}, 422)
              end
            end
          end
        end
      end
    end
  end
end
