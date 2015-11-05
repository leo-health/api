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
              error!({error_code: 422, error_message: user.errors.full_messages}, 422)
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
            error!({ error_code: 422, error_message: "Current password is not valid." }, 422) unless current_user.valid_password?(params[:current_password])
            error!({ error_code: 422, error_message: "password and password confirmation do not match" }, 422) unless params[:password] == params[:password_confirmation]
            unless current_user.reset_password(params[:password], params[:password_confirmation])
              error!({ error_code: 422, error_message: current_user.errors.full_messages }, 422)
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
              error!({ error_code: 422, error_message: "password and password confirmation do not match" }, 422) unless params[:password] == params[:password_confirmation]
              user = User.with_reset_password_token(params[:token])
              error!({error_code: 422, error_message: "Reset password period expired."}, 422) unless user.reset_password_period_valid?
              user = User.reset_password_by_token({reset_password_token: params[:token],
                                                   password: params[:password],
                                                   password_confirmation: params[:password_confirmation]})
              unless user.valid?
                error!({ error_code: 422, error_message: user.errors.full_messages }, 422)
              end
            end
          end
        end
      end
    end
  end
end
