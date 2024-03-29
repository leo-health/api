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
              user.send_reset_password_instructions and return
            else
              error!({error_code: 422, user_message: "Invalid email address"}, 422)
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
            user = current_user
            error!({ error_code: 422, user_message: "Current password is not valid." }, 422) unless user.valid_password?(params[:current_password])
            unless user.reset_password(params[:password], params[:password_confirmation])
              error!({ error_code: 422, user_message: user.errors.full_messages.first }, 422)
            else
              PasswordChangeConfirmationJob.send(user.id) and return
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
              error!({error_code: 401, user_message: "401 Unauthorized"}, 401) unless user = User.with_reset_password_token(params[:token])
              error!({error_code: 422, user_message: "Reset password period expired."}, 422) unless user.reset_password_period_valid?
              unless user.reset_password(params[:password], params[:password_confirmation])
                error!({ error_code: 422, user_message: user.errors.full_messages.first }, 422)
              end
            end
          end
        end
      end
    end
  end
end
